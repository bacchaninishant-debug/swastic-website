$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class GemProcessor {
    // Process image to Pure White Studio PNG (255, 255, 255 background with smooth natural shadow)
    public static void ProcessPureWhite(string srcPath, string destPath, double bgCutoff) {
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
                double bgRef = cornerSum / cornerSamples; // e.g. ~240

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

                        // Distance from center
                        double dx = x - w / 2.0;
                        double dy = y - h / 2.0;
                        double dist = Math.Sqrt(dx * dx + dy * dy);

                        // If it's pure background (far from center or very low saturation and high brightness)
                        // In gemstones, center has gem:
                        bool isFar = dist > (w * 0.44); // outer ring is guaranteed pure white
                        bool isOuterBg = dist > (w * 0.32) && maxDiff < 10 && bright > (bgRef - 15);

                        if (isFar || (maxDiff < 8 && bright >= bgRef - 4)) {
                            // Pure white background
                            destBytes[bidx] = 255;
                            destBytes[bidx + 1] = 255;
                            destBytes[bidx + 2] = 255;
                            destBytes[bidx + 3] = 255;
                        } else if (maxDiff < 14 && bright > (bgRef - 55)) {
                            // Soft shadow region
                            // Darkness below background:
                            double darkness = Math.Max(0.0, bgRef - bright);
                            // Radial fade so shadow naturally tapers to 255 at edges
                            double fade = 1.0;
                            if (dist > (w * 0.28)) {
                                fade = Math.Max(0.0, ((w * 0.42) - dist) / (w * 0.14));
                            }
                            double finalDark = darkness * fade * 1.05;
                            byte shadowVal = (byte)Math.Max(0, Math.Min(255, (int)Math.Round(255.0 - finalDark)));
                            destBytes[bidx] = shadowVal;
                            destBytes[bidx + 1] = shadowVal;
                            destBytes[bidx + 2] = shadowVal;
                            destBytes[bidx + 3] = 255;
                        } else {
                            // Gemstone itself: preserve pristine colors and facets
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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

    // Process image to Transparent PNG (Alpha channel for background, transparent soft shadow)
    public static void ProcessTransparent(string srcPath, string destPath) {
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
                double bgRef = cornerSum / cornerSamples;

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

                        bool isFar = dist > (w * 0.44);

                        if (isFar || (maxDiff < 8 && bright >= bgRef - 4)) {
                            // Fully transparent
                            destBytes[bidx] = 0;
                            destBytes[bidx + 1] = 0;
                            destBytes[bidx + 2] = 0;
                            destBytes[bidx + 3] = 0;
                        } else if (maxDiff < 14 && bright > (bgRef - 55)) {
                            // Soft contact shadow: black with alpha
                            double darkness = Math.Max(0.0, bgRef - bright);
                            double fade = 1.0;
                            if (dist > (w * 0.28)) {
                                fade = Math.Max(0.0, ((w * 0.42) - dist) / (w * 0.14));
                            }
                            double finalDark = darkness * fade;
                            // Alpha corresponds to darkness intensity (e.g. 50 darkness -> alpha ~ 0.35)
                            double alphaNorm = Math.Min(1.0, (finalDark / 70.0) * 0.65);
                            if (alphaNorm < 0.02) {
                                destBytes[bidx] = 0;
                                destBytes[bidx + 1] = 0;
                                destBytes[bidx + 2] = 0;
                                destBytes[bidx + 3] = 0;
                            } else {
                                destBytes[bidx] = 20; // dark charcoal shadow
                                destBytes[bidx + 1] = 20;
                                destBytes[bidx + 2] = 20;
                                destBytes[bidx + 3] = (byte)Math.Round(alphaNorm * 255.0);
                            }
                        } else {
                            // Gemstone
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[GemProcessor]::ProcessPureWhite("c:\Users\User\OneDrive\Desktop\veloraaaa\images\product-gem-green-beryl.jpg", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_purewhite.png", 238)
[GemProcessor]::ProcessTransparent("c:\Users\User\OneDrive\Desktop\veloraaaa\images\product-gem-green-beryl.jpg", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_transparent.png")
Write-Output "Both tests generated successfully!"
