$csharp = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class SpanExtractor {
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

                bool[] isMask = new bool[w * h];

                // For each horizontal row Y, find spans for:
                // 1) Paper + Tape (center area)
                // 2) Left Emerald (X < w/2)
                // 3) Right Emerald (X >= w/2)
                for (int y = 0; y < h; y++) {
                    int paperMinX = -1, paperMaxX = -1;
                    int leftGemMinX = -1, leftGemMaxX = -1;
                    int rightGemMinX = -1, rightGemMaxX = -1;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isPaperOrTape = (r > 80 && g > 70 && (b > 60 || r > 110));
                        bool isEmerald = (g >= 55 && (g >= r * 1.25 || (g > 65 && g >= b * 1.05))) && (r < 120);
                        bool isGlint = (g > 150 && b > 120);

                        if (isPaperOrTape && x > 100 && x < w - 80) {
                            if (paperMinX == -1) paperMinX = x;
                            paperMaxX = x;
                        }

                        if ((isEmerald || isGlint)) {
                            if (x < w * 0.45) {
                                if (leftGemMinX == -1) leftGemMinX = x;
                                leftGemMaxX = x;
                            } else if (x > w * 0.55) {
                                if (rightGemMinX == -1) rightGemMinX = x;
                                rightGemMaxX = x;
                            }
                        }
                    }

                    // Fill Paper span
                    if (paperMinX != -1 && paperMaxX != -1) {
                        for (int x = paperMinX; x <= paperMaxX; x++) {
                            isMask[y * w + x] = true;
                        }
                    }

                    // Fill Left Gem span
                    if (leftGemMinX != -1 && leftGemMaxX != -1) {
                        for (int x = 0; x <= leftGemMaxX; x++) { // gem touches left border
                            isMask[y * w + x] = true;
                        }
                    }

                    // Fill Right Gem span
                    if (rightGemMinX != -1 && rightGemMaxX != -1) {
                        for (int x = rightGemMinX; x < w; x++) { // gem touches right border
                            isMask[y * w + x] = true;
                        }
                    }
                }

                // Copy to dest
                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int idx = y * w + x;
                        int bidx = y * srcData.Stride + (x * 4);

                        if (isMask[idx]) {
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
[SpanExtractor]::Process("c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2.png", "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_why2_span.png")
Write-Host "Span extraction completed!"
