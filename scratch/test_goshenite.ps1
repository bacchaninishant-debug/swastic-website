Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class TestGoshenite {
    public static void Run() {
        string srcPath = @"c:\Users\User\OneDrive\Desktop\veloraaaa\images\product-gem-goshenite-diamond.jpg";
        string destPath = @"c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_goshenite_purewhite.png";
        
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

                // Sample corner background brightness
                double cornerSum = 0;
                int cornerSamples = 0;
                int[] sampleXs = { 5, 20, w - 20, w - 5 };
                int[] sampleYs = { 5, 20, h - 20, h - 5 };
                foreach (int sy in sampleYs) {
                    foreach (int sx in sampleXs) {
                        int idx = sy * srcData.Stride + sx * 4;
                        double br = (srcBytes[idx] + srcBytes[idx+1] + srcBytes[idx+2]) / 3.0;
                        cornerSum += br;
                        cornerSamples++;
                    }
                }
                double bgRef = cornerSum / cornerSamples; // ~238

                // Gem bbox: X=[270, 750], Y=[330, 695]
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + x * 4;
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        double bright = (r + g + b) / 3.0;
                        int diffRG = Math.Abs((int)r - (int)g);
                        int diffGB = Math.Abs((int)g - (int)b);
                        int diffRB = Math.Abs((int)r - (int)b);
                        int maxDiff = Math.Max(diffRG, Math.Max(diffGB, diffRB));

                        double dx = x - w / 2.0;
                        double dy = y - h / 2.0;
                        double dist = Math.Sqrt(dx * dx + dy * dy);

                        // If definitely outside gem and shadow:
                        bool isOuter = (x < 240 || x > 780 || y < 280 || y > 820);
                        if (isOuter) {
                            destBytes[bidx] = 255;
                            destBytes[bidx + 1] = 255;
                            destBytes[bidx + 2] = 255;
                            destBytes[bidx + 3] = 255;
                            continue;
                        }

                        // Inside gem bounds [270, 750] x [330, 695]
                        bool isInsideStoneBounds = (x >= 270 && x <= 750 && y >= 330 && y <= 695);
                        if (isInsideStoneBounds) {
                            // Check if this pixel is background around the corners of the stone's oval
                            // In Goshenite, facets have dark lines, fire (rainbow diff), or internal brilliance
                            // The studio background around the diamond is near bgRef (238) with maxDiff < 6
                            // But diamond sparkles might also be bright white (250-255).
                            // Note: background in the source image is NOT 255, it is ~238!
                            // Diamond bright facets are typically 245-255 (brighter than bgRef) or have dark facet lines (<200) or dispersion!
                            if (Math.Abs(bright - bgRef) < 5 && maxDiff < 5) {
                                // Background area near stone corners
                                destBytes[bidx] = 255;
                                destBytes[bidx + 1] = 255;
                                destBytes[bidx + 2] = 255;
                                destBytes[bidx + 3] = 255;
                            } else {
                                // Stone facet! Preserve completely!
                                destBytes[bidx] = b;
                                destBytes[bidx + 1] = g;
                                destBytes[bidx + 2] = r;
                                destBytes[bidx + 3] = 255;
                            }
                        } else if (y > 695 && y <= 820) {
                            // Shadow region below diamond
                            double darkness = Math.Max(0.0, bgRef - bright);
                            double fade = Math.Max(0.0, (820.0 - y) / 125.0);
                            double finalDark = darkness * fade;
                            byte shadowVal = (byte)Math.Max(0, Math.Min(255, (int)Math.Round(255.0 - finalDark)));
                            destBytes[bidx] = shadowVal;
                            destBytes[bidx + 1] = shadowVal;
                            destBytes[bidx + 2] = shadowVal;
                            destBytes[bidx + 3] = 255;
                        } else {
                            destBytes[bidx] = 255;
                            destBytes[bidx + 1] = 255;
                            destBytes[bidx + 2] = 255;
                            destBytes[bidx + 3] = 255;
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
"@ -ReferencedAssemblies "System.Drawing.dll"

[TestGoshenite]::Run()
Write-Output "Goshenite diamond test completed!"
