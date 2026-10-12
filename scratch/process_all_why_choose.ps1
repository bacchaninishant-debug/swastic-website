$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class WhyChooseCleaner {

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
                    int leftGemMax = -1;
                    int rightGemMin = -1;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        // Tape (y < 125)
                        if (y < 125 && x > 300 && x < 530) {
                            if (r > 130 && g > 70 && b < 80) {
                                if (tapeMin == -1) tapeMin = x;
                                tapeMax = x;
                            }
                        }

                        // Paper (y >= 100)
                        if (y >= 100 && x > 150 && x < 660) {
                            if (r > 75 && g > 75 && b > 65) {
                                if (paperMin == -1) paperMin = x;
                                paperMax = x;
                            }
                        }

                        // Left Emerald (y >= 350, x < 210)
                        if (y >= 350 && x < 210) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                leftGemMax = x;
                            }
                        }

                        // Right Emerald (y >= 360, x > 580)
                        if (y >= 360 && x > 580) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                if (rightGemMin == -1) rightGemMin = x;
                            }
                        }
                    }

                    if (tapeMin != -1 && tapeMax != -1) {
                        for (int x = tapeMin; x <= tapeMax; x++) isMask[y * w + x] = true;
                    }
                    if (paperMin != -1 && paperMax != -1) {
                        for (int x = paperMin; x <= paperMax; x++) isMask[y * w + x] = true;
                    }
                    if (leftGemMax != -1) {
                        for (int x = 0; x <= leftGemMax; x++) isMask[y * w + x] = true;
                    }
                    if (rightGemMin != -1) {
                        for (int x = rightGemMin; x < w; x++) isMask[y * w + x] = true;
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

    public static void ProcessImage3(string srcPath, string destPath) {
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
                    int leftGemMax = -1;
                    int rightGemMin = -1;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        // Tape (y < 125)
                        if (y < 125 && x > 240 && x < 480) {
                            if (r > 130 && g > 70 && b < 80) {
                                if (tapeMin == -1) tapeMin = x;
                                tapeMax = x;
                            }
                        }

                        // Paper (y >= 100)
                        if (y >= 100 && x > 110 && x < 600) {
                            if (r > 75 && g > 75 && b > 65) {
                                if (paperMin == -1) paperMin = x;
                                paperMax = x;
                            }
                        }

                        // Left Emerald (y >= 380, x < 180)
                        if (y >= 380 && x < 180) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                leftGemMax = x;
                            }
                        }

                        // Right Emerald (y >= 450, x > 540)
                        if (y >= 450 && x > 540) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                if (rightGemMin == -1) rightGemMin = x;
                            }
                        }
                    }

                    if (tapeMin != -1 && tapeMax != -1) {
                        for (int x = tapeMin; x <= tapeMax; x++) isMask[y * w + x] = true;
                    }
                    if (paperMin != -1 && paperMax != -1) {
                        for (int x = paperMin; x <= paperMax; x++) isMask[y * w + x] = true;
                    }
                    if (leftGemMax != -1) {
                        for (int x = 0; x <= leftGemMax; x++) isMask[y * w + x] = true;
                    }
                    if (rightGemMin != -1) {
                        for (int x = rightGemMin; x < w; x++) isMask[y * w + x] = true;
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

    public static void ProcessImage4(string srcPath, string destPath) {
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
                    int leftGemMax = -1;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        // Tape (y < 95)
                        if (y < 95 && x > 250 && x < 490) {
                            if (r > 130 && g > 70 && b < 80) {
                                if (tapeMin == -1) tapeMin = x;
                                tapeMax = x;
                            }
                        }

                        // Paper (y >= 70)
                        if (y >= 70 && x > 110 && x < 610) {
                            if (r > 75 && g > 75 && b > 65) {
                                if (paperMin == -1) paperMin = x;
                                paperMax = x;
                            }
                        }

                        // Left Emerald (y >= 390, x < 210)
                        if (y >= 390 && x < 210) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                leftGemMax = x;
                            }
                        }
                    }

                    if (tapeMin != -1 && tapeMax != -1) {
                        for (int x = tapeMin; x <= tapeMax; x++) isMask[y * w + x] = true;
                    }
                    if (paperMin != -1 && paperMax != -1) {
                        for (int x = paperMin; x <= paperMax; x++) isMask[y * w + x] = true;
                    }
                    if (leftGemMax != -1) {
                        for (int x = 0; x <= leftGemMax; x++) isMask[y * w + x] = true;
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
[WhyChooseCleaner]::ProcessImage2("$baseDir\why-choose-2.png", "$baseDir\why-choose-2.png")
[WhyChooseCleaner]::ProcessImage3("$baseDir\why-choose-3.png", "$baseDir\why-choose-3.png")
[WhyChooseCleaner]::ProcessImage4("$baseDir\why-choose-4.png", "$baseDir\why-choose-4.png")

Write-Host "Images 2, 3, 4 saved successfully!"
