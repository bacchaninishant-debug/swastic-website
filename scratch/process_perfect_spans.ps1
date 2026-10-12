$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class PerfectSpanCleaner {

    public static void ProcessImage2(string srcPath, string destPath) {
        byte[] fileBytes = File.ReadAllBytes(srcPath);
        using (MemoryStream ms = new MemoryStream(fileBytes))
        using (Bitmap src = new Bitmap(ms)) {
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

                for (int y = 0; y < h; y++) {
                    int tapeMin = -1, tapeMax = -1;
                    int paperMin = -1, paperMax = -1;
                    int leftGemMin = -1, leftGemMax = -1;
                    int rightGemMin = -1, rightGemMax = -1;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        // Tape (y between 40 and 125, x between 310 and 520)
                        if (y >= 40 && y <= 125 && x >= 310 && x <= 520) {
                            if (r > 120 && g > 65 && b < 80) {
                                if (tapeMin == -1) tapeMin = x;
                                tapeMax = x;
                            }
                        }

                        // Paper (y >= 95 && y <= 630, x between 165 and 645)
                        if (y >= 95 && y <= 630 && x >= 165 && x <= 645) {
                            // Paper brightness
                            if (r > 80 && g > 80 && b > 70) {
                                if (paperMin == -1) paperMin = x;
                                paperMax = x;
                            }
                        }

                        // Left Emerald (y >= 350, x < 210)
                        if (y >= 350 && x < 210) {
                            // Emerald green or cyan glint
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                if (leftGemMin == -1) leftGemMin = x;
                                leftGemMax = x;
                            }
                        }

                        // Right Emerald (y >= 360, x > 580)
                        if (y >= 360 && x > 580) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                if (rightGemMin == -1) rightGemMin = x;
                                rightGemMax = x;
                            }
                        }
                    }

                    if (tapeMin != -1 && tapeMax != -1) {
                        for (int x = tapeMin; x <= tapeMax; x++) isMask[y * w + x] = true;
                    }
                    if (paperMin != -1 && paperMax != -1) {
                        for (int x = paperMin; x <= paperMax; x++) isMask[y * w + x] = true;
                    }
                    if (leftGemMin != -1 && leftGemMax != -1) {
                        for (int x = 0; x <= leftGemMax; x++) isMask[y * w + x] = true; // gem starts at left edge
                    }
                    if (rightGemMin != -1 && rightGemMax != -1) {
                        for (int x = rightGemMin; x < w; x++) isMask[y * w + x] = true; // gem goes to right edge
                    }
                }

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
                            destBytes[bidx] = 0; destBytes[bidx+1] = 0; destBytes[bidx+2] = 0; destBytes[bidx+3] = 0;
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
$baseDir = "c:\Users\User\OneDrive\Desktop\veloraaaa\images"
[PerfectSpanCleaner]::ProcessImage2("$baseDir\why-choose-2-orig.png", "$baseDir\why-choose-2.png")
Write-Host "Processed why-choose-2.png successfully!"
