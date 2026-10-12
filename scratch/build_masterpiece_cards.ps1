$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class LuxuryNotesBuilder {

    // Extract isolated transparent paper + tape from orig image
    public static Bitmap ExtractPaperAndTape(string srcPath, int tapeXMin, int tapeXMax, int tapeYMin, int tapeYMax,
                                            int paperXMin, int paperXMax, int paperYMin, int paperYMax) 
    {
        byte[] bytes = File.ReadAllBytes(srcPath);
        using (MemoryStream ms = new MemoryStream(bytes))
        using (Bitmap src = new Bitmap(ms)) {
            int w = src.Width;
            int h = src.Height;
            Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb);
            Rectangle rect = new Rectangle(0, 0, w, h);
            BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData destData = dest.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            int totalBytes = Math.Abs(srcData.Stride) * h;
            byte[] sBytes = new byte[totalBytes];
            byte[] dBytes = new byte[totalBytes];
            Marshal.Copy(srcData.Scan0, sBytes, 0, totalBytes);

            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    int bidx = y * srcData.Stride + (x * 4);
                    byte b = sBytes[bidx];
                    byte g = sBytes[bidx + 1];
                    byte r = sBytes[bidx + 2];

                    bool keep = false;

                    // Tape area
                    if (x >= tapeXMin && x <= tapeXMax && y >= tapeYMin && y <= tapeYMax) {
                        // Tape is amber/gold: r > 110, g > 55, b < 90
                        if (r > 105 && g > 55 && b < 100) keep = true;
                    }

                    // Paper area
                    if (x >= paperXMin && x <= paperXMax && y >= paperYMin && y <= paperYMax) {
                        // Paper is off-white or gray lines/ink:
                        // Background is r <= 18, g in [20..50], b in [20..50], |g-b| <= 8
                        bool isBg = (r <= 20 && g >= 18 && g <= 55 && b >= 18 && b <= 52 && Math.Abs(g - b) <= 9);
                        if (!isBg) {
                            // Also make sure it's not corner gem facets if any:
                            // Paper pixels have either: (r > 60 && g > 60 && b > 55) OR dark ink lines
                            if (r > 60 && g > 60 && b > 50) keep = true;
                            else if (r > 25 && g > 25 && b > 25 && Math.Abs(r - g) < 25 && Math.Abs(g - b) < 25) keep = true;
                        }
                    }

                    if (keep) {
                        dBytes[bidx] = b;
                        dBytes[bidx + 1] = g;
                        dBytes[bidx + 2] = r;
                        dBytes[bidx + 3] = 255;
                    } else {
                        dBytes[bidx] = 0;
                        dBytes[bidx + 1] = 0;
                        dBytes[bidx + 2] = 0;
                        dBytes[bidx + 3] = 0;
                    }
                }
            }

            Marshal.Copy(dBytes, 0, destData.Scan0, totalBytes);
            src.UnlockBits(srcData);
            dest.UnlockBits(destData);
            return dest;
        }
    }

    // Extract transparent gem from white background HD gem
    public static Bitmap ExtractTransparentGem(string gemPath) {
        byte[] bytes = File.ReadAllBytes(gemPath);
        using (MemoryStream ms = new MemoryStream(bytes))
        using (Bitmap src = new Bitmap(ms)) {
            int w = src.Width;
            int h = src.Height;
            Bitmap dest = new Bitmap(w, h, PixelFormat.Format32bppArgb);
            Rectangle rect = new Rectangle(0, 0, w, h);
            BitmapData srcData = src.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData destData = dest.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            int totalBytes = Math.Abs(srcData.Stride) * h;
            byte[] sBytes = new byte[totalBytes];
            byte[] dBytes = new byte[totalBytes];
            Marshal.Copy(srcData.Scan0, sBytes, 0, totalBytes);

            for (int y = 0; y < h; y++) {
                for (int x = 0; x < w; x++) {
                    int bidx = y * srcData.Stride + (x * 4);
                    byte b = sBytes[bidx];
                    byte g = sBytes[bidx + 1];
                    byte r = sBytes[bidx + 2];

                    // White background check:
                    if (r > 240 && g > 240 && b > 240) {
                        dBytes[bidx] = 0; dBytes[bidx+1] = 0; dBytes[bidx+2] = 0; dBytes[bidx+3] = 0;
                    } else if (r > 215 && g > 215 && b > 215) {
                        // Soft antialiased edge
                        float factor = (255f - (r + g + b)/3f) / 40f;
                        byte alpha = (byte)Math.Min(255, Math.Max(0, (int)(factor * 255)));
                        dBytes[bidx] = b; dBytes[bidx+1] = g; dBytes[bidx+2] = r; dBytes[bidx+3] = alpha;
                    } else {
                        dBytes[bidx] = b; dBytes[bidx+1] = g; dBytes[bidx+2] = r; dBytes[bidx+3] = 255;
                    }
                }
            }

            Marshal.Copy(dBytes, 0, destData.Scan0, totalBytes);
            src.UnlockBits(srcData);
            dest.UnlockBits(destData);
            return dest;
        }
    }

    public static void BuildAll(string imagesDir) {
        // 1. Extract Paper Notes
        Bitmap paper1 = ExtractPaperAndTape(Path.Combine(imagesDir, "why-choose-2-orig.png"), 310, 520, 30, 125, 160, 650, 90, 635);
        Bitmap paper2 = ExtractPaperAndTape(Path.Combine(imagesDir, "why-choose-3-orig.png"), 260, 480, 30, 125, 120, 610, 90, 600);
        Bitmap paper3 = ExtractPaperAndTape(Path.Combine(imagesDir, "why-choose-4-orig.png"), 260, 490, 15, 95, 120, 615, 60, 580);

        // 2. Extract HD Gems
        Bitmap gemRound = ExtractTransparentGem(Path.Combine(imagesDir, "gem-emerald-round-hd.jpg"));
        Bitmap gemPear = ExtractTransparentGem(Path.Combine(imagesDir, "gem-emerald-pear-hd.jpg"));
        Bitmap gemEmerald = ExtractTransparentGem(Path.Combine(imagesDir, "gem-emerald-emerald-hd.jpg"));

        // 3. Composite Card 1: Note 1 + Round Emerald at bottom-left
        int canvasW = 680;
        int canvasH = 680;

        using (Bitmap card1 = new Bitmap(canvasW, canvasH, PixelFormat.Format32bppArgb))
        using (Graphics g = Graphics.FromImage(card1)) {
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.Clear(Color.Transparent);

            // Draw Paper 1
            g.DrawImage(paper1, 0, 0, canvasW, canvasH);

            // Draw Round Emerald overlapping bottom-left corner of paper
            // Paper bottom-left is around x: 180, y: 550.
            // Place round gem at x: 20, y: 440, size: 240 x 240
            g.DrawImage(gemRound, new Rectangle(10, 430, 240, 240));

            card1.Save(Path.Combine(imagesDir, "why-choose-card-1.png"), ImageFormat.Png);
        }

        // 4. Composite Card 2: Note 2 + Pear Emerald at bottom-left
        using (Bitmap card2 = new Bitmap(canvasW, canvasH, PixelFormat.Format32bppArgb))
        using (Graphics g = Graphics.FromImage(card2)) {
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.Clear(Color.Transparent);

            g.DrawImage(paper2, 0, 0, canvasW, canvasH);

            // Place Pear gem at x: 15, y: 410, size: 220 x 260
            g.DrawImage(gemPear, new Rectangle(15, 410, 220, 260));

            card2.Save(Path.Combine(imagesDir, "why-choose-card-2.png"), ImageFormat.Png);
        }

        // 5. Composite Card 3: Note 3 + Step-Cut Emerald at bottom-left
        using (Bitmap card3 = new Bitmap(canvasW, canvasH, PixelFormat.Format32bppArgb))
        using (Graphics g = Graphics.FromImage(card3)) {
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.Clear(Color.Transparent);

            g.DrawImage(paper3, 0, 0, canvasW, canvasH);

            // Place Step-Cut gem at x: 15, y: 430, size: 230 x 240
            g.DrawImage(gemEmerald, new Rectangle(15, 430, 230, 240));

            card3.Save(Path.Combine(imagesDir, "why-choose-card-3.png"), ImageFormat.Png);
        }

        paper1.Dispose(); paper2.Dispose(); paper3.Dispose();
        gemRound.Dispose(); gemPear.Dispose(); gemEmerald.Dispose();

        Console.WriteLine("Masterpiece cards 1, 2, 3 built successfully!");
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[LuxuryNotesBuilder]::BuildAll("c:\Users\User\OneDrive\Desktop\veloraaaa\images")
