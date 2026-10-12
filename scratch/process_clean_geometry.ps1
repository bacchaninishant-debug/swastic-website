$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class WhyChooseCleanerClean {

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

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isFg = false;

                        // 1. Tape
                        if (x >= 320 && x <= 520 && y >= 45 && y <= 125) {
                            if (r > 120 && g > 60 && b < 80) isFg = true;
                        }

                        // 2. Paper
                        if (x >= 170 && x <= 645 && y >= 105 && y <= 625) {
                            // Any pixel that is paper or ink (not dark background)
                            if (r > 70 || g > 70 || b > 65) isFg = true;
                        }

                        // 3. Left Emerald (ellipse)
                        double dxL = (double)(x - 0) / 185.0;
                        double dyL = (double)(y - 580) / 165.0;
                        if (dxL * dxL + dyL * dyL <= 1.0) isFg = true;

                        // 4. Right Emerald (ellipse)
                        double dxR = (double)(x - w) / 185.0;
                        double dyR = (double)(y - 580) / 165.0;
                        if (dxR * dxR + dyR * dyR <= 1.0) isFg = true;

                        if (isFg) {
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isFg = false;

                        // 1. Tape
                        if (x >= 265 && x <= 465 && y >= 45 && y <= 125) {
                            if (r > 120 && g > 60 && b < 80) isFg = true;
                        }

                        // 2. Paper
                        if (x >= 135 && x <= 590 && y >= 105 && y <= 600) {
                            if (r > 70 || g > 70 || b > 65) isFg = true;
                        }

                        // 3. Left Emerald (ellipse)
                        double dxL = (double)(x - 0) / 175.0;
                        double dyL = (double)(y - 565) / 175.0;
                        if (dxL * dxL + dyL * dyL <= 1.0) isFg = true;

                        // 4. Right Emerald (ellipse)
                        double dxR = (double)(x - w) / 180.0;
                        double dyR = (double)(y - 565) / 175.0;
                        if (dxR * dxR + dyR * dyR <= 1.0) isFg = true;

                        if (isFg) {
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isFg = false;

                        // 1. Tape
                        if (x >= 275 && x <= 475 && y >= 15 && y <= 95) {
                            if (r > 120 && g > 60 && b < 80) isFg = true;
                        }

                        // 2. Paper
                        if (x >= 145 && x <= 610 && y >= 70 && y <= 575) {
                            if (r > 70 || g > 70 || b > 65) isFg = true;
                        }

                        // 3. Left Emerald (ellipse)
                        double dxL = (double)(x - 0) / 205.0;
                        double dyL = (double)(y - 570) / 180.0;
                        if (dxL * dxL + dyL * dyL <= 1.0) isFg = true;

                        if (isFg) {
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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

    public static void ProcessImage1(string srcPath, string destPath) {
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

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        bool isFg = false;

                        // 1. Silver/White Text
                        if (y < 490 && x >= 30 && x <= 490) {
                            if (r > 60 && g > 65 && b > 65) isFg = true;
                        }

                        // 2. Left Emerald
                        double dxL = (double)(x - 0) / 140.0;
                        double dyL = (double)(y - 620) / 140.0;
                        if (dxL * dxL + dyL * dyL <= 1.0) isFg = true;

                        // 3. Right Emerald
                        double dxR = (double)(x - w) / 140.0;
                        double dyR = (double)(y - 620) / 140.0;
                        if (dxR * dxR + dyR * dyR <= 1.0) isFg = true;

                        if (isFg) {
                            destBytes[bidx] = b;
                            destBytes[bidx + 1] = g;
                            destBytes[bidx + 2] = r;
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

# Backup originals first if not already backed up
$baseDir = "c:\Users\User\OneDrive\Desktop\veloraaaa\images"
if (!(Test-Path "$baseDir\why-choose-2-orig.png")) {
    Copy-Item "$baseDir\why-choose-swastic-2.png" "$baseDir\why-choose-2-orig.png" -Force
    Copy-Item "$baseDir\why-choose-swastic-3.png" "$baseDir\why-choose-3-orig.png" -Force
    Copy-Item "$baseDir\why-choose-swastic-4.png" "$baseDir\why-choose-4-orig.png" -Force
    Copy-Item "$baseDir\why-choose-1.png" "$baseDir\why-choose-1-orig.png" -Force
}

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"

[WhyChooseCleanerClean]::ProcessImage2("$baseDir\why-choose-2-orig.png", "$baseDir\why-choose-2.png")
[WhyChooseCleanerClean]::ProcessImage3("$baseDir\why-choose-3-orig.png", "$baseDir\why-choose-3.png")
[WhyChooseCleanerClean]::ProcessImage4("$baseDir\why-choose-4-orig.png", "$baseDir\why-choose-4.png")
[WhyChooseCleanerClean]::ProcessImage1("$baseDir\why-choose-1-orig.png", "$baseDir\why-choose-1.png")

Write-Host "All 4 why-choose images cleaned with precision geometric mask!"
