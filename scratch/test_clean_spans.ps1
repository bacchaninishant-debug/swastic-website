$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class CleanSpans {

    public static void ProcessImage(string srcPath, string destPath, 
        int tapeYMin, int tapeYMax, int tapeXMin, int tapeXMax,
        int paperYMin, int paperYMax, int paperXMin, int paperXMax,
        bool hasLeftGem, int leftGemYMin, int leftGemXMaxBound,
        bool hasRightGem, int rightGemYMin, int rightGemXMinBound) 
    {
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
                    int leftGemMax = -1, leftGemCount = 0;
                    int rightGemMin = -1, rightGemCount = 0;

                    for (int x = 0; x < w; x++) {
                        int bidx = y * srcData.Stride + (x * 4);
                        byte b = srcBytes[bidx];
                        byte g = srcBytes[bidx + 1];
                        byte r = srcBytes[bidx + 2];

                        // Tape
                        if (y >= tapeYMin && y <= tapeYMax && x >= tapeXMin && x <= tapeXMax) {
                            if (r > 120 && g > 65 && b < 80) {
                                if (tapeMin == -1) tapeMin = x;
                                tapeMax = x;
                            }
                        }

                        // Paper
                        if (y >= paperYMin && y <= paperYMax && x >= paperXMin && x <= paperXMax) {
                            if (r > 75 && g > 75 && b > 65) {
                                if (paperMin == -1) paperMin = x;
                                paperMax = x;
                            }
                        }

                        // Left Emerald
                        if (hasLeftGem && y >= leftGemYMin && x <= leftGemXMaxBound) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                leftGemMax = x;
                                leftGemCount++;
                            }
                        }

                        // Right Emerald
                        if (hasRightGem && y >= rightGemYMin && x >= rightGemXMinBound) {
                            if (g >= 48 && (g >= r * 1.25 || (g > 60 && g >= b * 1.05))) {
                                if (rightGemMin == -1) rightGemMin = x;
                                rightGemCount++;
                            }
                        }
                    }

                    if (tapeMin != -1 && tapeMax != -1) {
                        for (int x = tapeMin; x <= tapeMax; x++) isMask[y * w + x] = true;
                    }
                    if (paperMin != -1 && paperMax != -1) {
                        for (int x = paperMin; x <= paperMax; x++) isMask[y * w + x] = true;
                    }
                    if (hasLeftGem && leftGemMax != -1 && leftGemCount >= 15) {
                        for (int x = 0; x <= leftGemMax; x++) isMask[y * w + x] = true;
                    }
                    if (hasRightGem && rightGemMin != -1 && rightGemCount >= 15) {
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
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
$baseDir = "c:\Users\User\OneDrive\Desktop\veloraaaa\images"

# Process Image 2
[CleanSpans]::ProcessImage(
    "$baseDir\why-choose-2-orig.png", "$baseDir\why-choose-2.png",
    40, 125, 310, 520,  # Tape
    95, 630, 165, 645,  # Paper
    $true, 520, 195,    # Left gem (y >= 520, x <= 195)
    $true, 530, 580     # Right gem (y >= 530, x >= 580)
)

# Process Image 3
[CleanSpans]::ProcessImage(
    "$baseDir\why-choose-3-orig.png", "$baseDir\why-choose-3.png",
    40, 125, 245, 475,  # Tape
    100, 595, 120, 590, # Paper
    $true, 525, 180,    # Left gem (y >= 525, x <= 180)
    $true, 535, 545     # Right gem (y >= 535, x >= 545)
)

# Process Image 4
[CleanSpans]::ProcessImage(
    "$baseDir\why-choose-4-orig.png", "$baseDir\why-choose-4.png",
    15, 95, 260, 485,   # Tape
    65, 575, 130, 610,  # Paper
    $true, 530, 205,    # Left gem (y >= 530, x <= 205)
    $false, 0, 0        # No right gem
)

Write-Host "Images 2, 3, 4 processed cleanly without any spikes or boxes!"
