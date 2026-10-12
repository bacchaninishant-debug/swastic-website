$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class ForegroundExtractor {
    public static void Process(string srcPath, string destPath) {
        using (Bitmap src = new Bitmap(srcPath)) {
            int w = src.Width;
            int h = src.Height;
            using (Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
                Rectangle rect = new Rectangle(0, 0, w, h);
                BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                BitmapData destData = dest.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

                int bytes = Math.Abs(srcData.Stride) * h;
                byte[] srcBytes = new byte[bytes];
                byte[] destBytes = new byte[bytes];
                Marshal.Copy(srcData.Scan0, srcBytes, 0, bytes);

                bool[] isForeground = new bool[w * h];

                // Step 1: Detect seed foreground pixels
                // A pixel is definitely foreground if:
                // 1) Paper: R > 100 && G > 100 && B > 100
                // 2) Tape: R > 110 && G > 65 && B < 80
                // 3) Emerald: G > 55 && (G > R * 1.3 || (G > 70 && G > B * 1.1))
                // 4) Sparkle/Glint: (R > 120 && G > 180 && B > 140)
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isPaper = (r > 90 && g > 90 && b > 90);
                        bool isTape = (r > 100 && g > 60 && b < 70);
                        bool isEmerald = (g >= 55 && (g >= r * 1.30 || (g > 65 && g >= b * 1.05))) && (r < 120);
                        bool isGlint = (g > 150 && b > 120);

                        if (isPaper || isTape || isEmerald || isGlint) {
                            isForeground[y * w + x] = true;
                        }
                    }
                }

                // Step 2: Morphological Close to fill in ink text, lines, holes in paper, and dark facet lines in emeralds
                // Dilation (radius 6) followed by Erosion (radius 6)
                int radius = 6;
                bool[] dilated = new bool[w * h];

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        bool anyFg = false;
                        for (int dy = -radius; dy <= radius && !anyFg; dy++) {
                            int ny = y + dy;
                            if (ny < 0 || ny >= h) continue;
                            for (int dx = -radius; dx <= radius; dx++) {
                                int nx = x + dx;
                                if (nx < 0 || nx >= w) continue;
                                if (dx * dx + dy * dy <= radius * radius) {
                                    if (isForeground[ny * w + nx]) {
                                        anyFg = true;
                                        break;
                                    }
                                }
                            }
                        }
                        dilated[y * w + x] = anyFg;
                    }
                }

                bool[] closed = new bool[w * h];
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        bool allDilated = true;
                        for (int dy = -radius; dy <= radius && allDilated; dy++) {
                            int ny = y + dy;
                            if (ny < 0 || ny >= h) continue;
                            for (int dx = -radius; dx <= radius; dx++) {
                                int nx = x + dx;
                                if (nx < 0 || nx >= w) continue;
                                if (dx * dx + dy * dy <= radius * radius) {
                                    if (!dilated[ny * w + nx]) {
                                        allDilated = false;
                                        break;
                                    }
                                }
                            }
                        }
                        closed[y * w + x] = allDilated;
                    }
                }

                // Step 3: Copy to dest with smooth edge feathering
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * srcData.Stride + (x * 4);

                        if (closed[idx]) {
                            destBytes[bidx] = srcBytes[bidx];
                            destBytes[bidx + 1] = srcBytes[bidx + 1];
                            destBytes[bidx + 2] = srcBytes[bidx + 2];
                            destBytes[bidx + 3] = 255;
                        } else {
                            destBytes[bidx] = 0;
                            destBytes[bidx + 1] = 0;
                            destBytes[bidx + 2] = 0;
                            destBytes[bidx + 3] = 0;
                        }
                    }
                }

                Marshal.Copy(destBytes, 0, destData.Scan0, bytes);
                src.UnlockBits(srcData);
                dest.UnlockBits(destData);
                dest.Save(destPath, ImageFormat.Png);
            }
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[ForegroundExtractor]::Process("c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2.png", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_why2_morph.png")
Write-Host "Morphological extraction completed!"
