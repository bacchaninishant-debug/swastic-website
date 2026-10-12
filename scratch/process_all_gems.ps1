$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class UniversalGemRetoucher {
    public static void ProcessGem(string srcPath, string destWhitePng, string destTransparentPng, int minX, int maxX, int minY, int maxY) {
        using (Bitmap src = new Bitmap(srcPath)) {
            int w = src.Width;
            int h = src.Height;

            using (Bitmap destWhite = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            using (Bitmap destTrans = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
                Rectangle rect = new Rectangle(0, 0, w, h);
                BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                BitmapData whiteData = destWhite.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                BitmapData transData = destTrans.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

                int bytes = Math.Abs(srcData.Stride) * h;
                byte[] srcBytes = new byte[bytes];
                byte[] whiteBytes = new byte[bytes];
                byte[] transBytes = new byte[bytes];
                Marshal.Copy(srcData.Scan0, srcBytes, 0, bytes);

                // 1. Calculate average background color from edges
                double bgR = 0, bgG = 0, bgB = 0;
                int edgeCount = 0;
                for (int x = 0; x < w; x += 10) {
                    int iTop = (0 * srcData.Stride) + (x * 4);
                    int iBot = ((h - 1) * srcData.Stride) + (x * 4);
                    bgB += srcBytes[iTop]; bgG += srcBytes[iTop+1]; bgR += srcBytes[iTop+2];
                    bgB += srcBytes[iBot]; bgG += srcBytes[iBot+1]; bgR += srcBytes[iBot+2];
                    edgeCount += 2;
                }
                bgR /= edgeCount; bgG /= edgeCount; bgB /= edgeCount;
                double bgBright = (bgR + bgG + bgB) / 3.0;

                // 2. Flood fill from borders to identify outer background
                bool[] isBg = new bool[w * h];
                int[] qx = new int[w * h];
                int[] qy = new int[w * h];
                int head = 0, tail = 0;

                for (int x = 0; x < w; x++) {
                    qx[tail] = x; qy[tail] = 0; isBg[x] = true; tail++;
                    qx[tail] = x; qy[tail] = h - 1; isBg[(h - 1) * w + x] = true; tail++;
                }
                for (int y = 0; y < h; y++) {
                    if (!isBg[y * w]) { qx[tail] = 0; qy[tail] = y; isBg[y * w] = true; tail++; }
                    if (!isBg[y * w + (w - 1)]) { qx[tail] = w - 1; qy[tail] = y; isBg[y * w + (w - 1)] = true; tail++; }
                }

                int[] dx = { 1, -1, 0, 0 };
                int[] dy = { 0, 0, 1, -1 };

                // Tolerance for background floodfill:
                // Background pixels are within ~8 of bgRef and low saturation
                while (head < tail) {
                    int cx = qx[head];
                    int cy = qy[head];
                    head++;

                    for (int i = 0; i < 4; i++) {
                        int nx = cx + dx[i];
                        int ny = cy + dy[i];
                        if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                            int nidx = ny * w + nx;
                            if (!isBg[nidx]) {
                                // Don't penetrate deep inside the known gemstone core
                                bool inStoneCore = (nx >= (minX + 25) && nx <= (maxX - 25) && ny >= (minY + 25) && ny <= (maxY - 25));
                                if (!inStoneCore) {
                                    int bidx = ny * srcData.Stride + (nx * 4);
                                    byte b = srcBytes[bidx];
                                    byte g = srcBytes[bidx + 1];
                                    byte r = srcBytes[bidx + 2];
                                    double bright = (r + g + b) / 3.0;

                                    int diffRG = Math.Abs((int)r - (int)g);
                                    int diffGB = Math.Abs((int)g - (int)b);
                                    int diffRB = Math.Abs((int)r - (int)b);
                                    int maxDiff = Math.Max(diffRG, Math.Max(diffGB, diffRB));

                                    // If pixel is close to background level and low saturation, it's background
                                    // Shadows have lower brightness (bright < bgBright - 12), so floodfill won't cross deep shadow
                                    if (maxDiff < 9 && Math.Abs(bright - bgBright) < 14) {
                                        isBg[nidx] = true;
                                        qx[tail] = nx;
                                        qy[tail] = ny;
                                        tail++;
                                    }
                                }
                            }
                        }
                    }
                }

                // 3. Render output pixels
                double centerX = (minX + maxX) / 2.0;
                double centerY = (minY + maxY) / 2.0;
                double stoneRadiusX = (maxX - minX) / 2.0;
                double stoneRadiusY = (maxY - minY) / 2.0;

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * srcData.Stride + (x * 4);

                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        double bright = (r + g + b) / 3.0;
                        int diffRG = Math.Abs((int)r - (int)g);
                        int diffGB = Math.Abs((int)g - (int)b);
                        int diffRB = Math.Abs((int)r - (int)b);
                        int maxDiff = Math.Max(diffRG, Math.Max(diffGB, diffRB));

                        // Distance from stone
                        double nx = (x - centerX) / (stoneRadiusX + 5);
                        double ny = (y - centerY) / (stoneRadiusY + 5);
                        double normDist = Math.Sqrt(nx * nx + ny * ny);

                        // If marked as floodfill background OR outside the gemstone + shadow envelope:
                        bool isDefiniteBg = isBg[idx] || normDist > 1.45 || (x < (minX - 40)) || (x > (maxX + 40)) || (y < (minY - 40)) || (y > (maxY + 120));

                        if (isDefiniteBg) {
                            // Pure white output
                            whiteBytes[bidx] = 255;
                            whiteBytes[bidx + 1] = 255;
                            whiteBytes[bidx + 2] = 255;
                            whiteBytes[bidx + 3] = 255;

                            // Transparent output
                            transBytes[bidx] = 0;
                            transBytes[bidx + 1] = 0;
                            transBytes[bidx + 2] = 0;
                            transBytes[bidx + 3] = 0;
                        } else {
                            // Inside bounding envelope: check if shadow or stone
                            // Shadow region is below gem center (y > centerY), has low color saturation (maxDiff < 14) and brightness < bgBright
                            bool isShadow = (y > centerY && maxDiff < 14 && bright < (bgBright - 3) && normDist >= 0.95);

                            if (isShadow) {
                                double darkness = Math.Max(0.0, bgBright - bright);
                                // Fade shadow towards edges
                                double distFade = Math.Max(0.0, Math.Min(1.0, (1.40 - normDist) / 0.40));
                                double finalDark = darkness * distFade * 1.1;

                                byte shadowVal = (byte)Math.Max(0, Math.Min(255, (int)Math.Round(255.0 - finalDark)));
                                whiteBytes[bidx] = shadowVal;
                                whiteBytes[bidx + 1] = shadowVal;
                                whiteBytes[bidx + 2] = shadowVal;
                                whiteBytes[bidx + 3] = 255;

                                double alpha = Math.Min(1.0, (finalDark / 65.0) * 0.70);
                                if (alpha < 0.02) {
                                    transBytes[bidx] = 0;
                                    transBytes[bidx + 1] = 0;
                                    transBytes[bidx + 2] = 0;
                                    transBytes[bidx + 3] = 0;
                                } else {
                                    transBytes[bidx] = 15;
                                    transBytes[bidx + 1] = 15;
                                    transBytes[bidx + 2] = 15;
                                    transBytes[bidx + 3] = (byte)Math.Round(alpha * 255.0);
                                }
                            } else {
                                // Gemstone pixel: preserve 100% original RGB facets & fire!
                                whiteBytes[bidx] = b;
                                whiteBytes[bidx + 1] = g;
                                whiteBytes[bidx + 2] = r;
                                whiteBytes[bidx + 3] = 255;

                                transBytes[bidx] = b;
                                transBytes[bidx + 1] = g;
                                transBytes[bidx + 2] = r;
                                transBytes[bidx + 3] = 255;
                            }
                        }
                    }
                }

                Marshal.Copy(whiteBytes, 0, whiteData.Scan0, bytes);
                Marshal.Copy(transBytes, 0, transData.Scan0, bytes);

                src.UnlockBits(srcData);
                destWhite.UnlockBits(whiteData);
                destTrans.UnlockBits(transData);

                destWhite.Save(destWhitePng, ImageFormat.Png);
                if (!string.IsNullOrEmpty(destTransparentPng)) {
                    destTrans.Save(destTransparentPng, ImageFormat.Png);
                }
            }
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"

$gems = @(
    @{ name = "product-gem-green-beryl"; minX = 270; maxX = 755; minY = 295; maxY = 750 },
    @{ name = "product-gem-emerald"; minX = 275; maxX = 745; minY = 280; maxY = 785 },
    @{ name = "product-gem-aquamarine"; minX = 275; maxX = 750; minY = 270; maxY = 780 },
    @{ name = "product-gem-maxixe"; minX = 270; maxX = 755; minY = 320; maxY = 725 },
    @{ name = "product-gem-red-beryl"; minX = 250; maxX = 770; minY = 310; maxY = 740 },
    @{ name = "product-gem-morganite"; minX = 320; maxX = 700; minY = 260; maxY = 780 },
    @{ name = "product-gem-goshenite-diamond"; minX = 270; maxX = 750; minY = 330; maxY = 695 },
    @{ name = "product-gem-heliodor"; minX = 290; maxX = 730; minY = 345; maxY = 725 }
)

$imgDir = "c:\Users\User\OneDrive\Desktop\veloraaaa\images"

foreach ($g in $gems) {
    $src = Join-Path $imgDir ($g.name + ".jpg")
    $destWhite = Join-Path $imgDir ($g.name + ".png")
    $destTrans = Join-Path $imgDir ($g.name + "-transparent.png")
    
    [UniversalGemRetoucher]::ProcessGem($src, $destWhite, $destTrans, $g.minX, $g.maxX, $g.minY, $g.maxY)
    Write-Output "Processed $($g.name): Generated pure-white PNG and transparent PNG!"
}

# Also convert the 4 New Arrivals pairs to lossless pure-white PNG
$pairs = @(
    "pair-paraiba-tourmaline",
    "pair-chrome-tourmaline-5ct",
    "pair-chrome-tourmaline-8ct",
    "pair-chrome-tourmaline-10ct"
)

foreach ($p in $pairs) {
    $src = Join-Path $imgDir ($p + ".jpg")
    $dest = Join-Path $imgDir ($p + ".png")
    if (Test-Path $src) {
        $bmp = [System.Drawing.Bitmap]::FromFile($src)
        $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Output "Exported $p.png"
    }
}

Write-Output "ALL GEMSTONES COMPLETED SUCCESSFULLY!"
