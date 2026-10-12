$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class PerfectNotesV2 {
    public static void Run(string baseDir) {
        Bitmap img1 = new Bitmap(Path.Combine(baseDir, "why-choose-1-orig.png"));
        Bitmap img2 = new Bitmap(Path.Combine(baseDir, "why-choose-2-orig.png"));
        Bitmap img3 = new Bitmap(Path.Combine(baseDir, "why-choose-3-orig.png"));
        Bitmap img4 = new Bitmap(Path.Combine(baseDir, "why-choose-4-orig.png"));

        // =========================================================================
        // CARD 2: Note 2 + Full Pear Emerald
        // =========================================================================
        int c2W = 760;
        int c2H = 690;
        using (Bitmap card2 = new Bitmap(c2W, c2H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card2)) {
                g.Clear(Color.Transparent);
                // Draw Note 2 from img3 starting at x = 145. Note: img3 has 5px of bg at left edge, so start sample at x=5
                g.DrawImage(img3, new Rectangle(145, 0, 615, 690), new Rectangle(5, 0, 615, 690), GraphicsUnit.Pixel);

                // Draw Pear Left Half from img2 (x: 533 to 678, y: 420 to 688). Width = 146
                // Drawn at x = 0 to 146
                g.DrawImage(img2, new Rectangle(0, 420, 146, 270), new Rectangle(533, 420, 146, 270), GraphicsUnit.Pixel);
            }

            // Remove any leftover paper from img2 on the left of pear (x < 140, y < 510 where it's paper white)
            for (int y = 0; y < c2H; y++) {
                for (int x = 0; x < 140; x++) {
                    Color c = card2.GetPixel(x, y);
                    // If it's not gem (i.e. paper white or top bg):
                    if (y < 420 || (c.R > 80 && c.G > 80 && c.B > 80 && Math.Abs(c.R - c.G) < 20)) {
                        card2.SetPixel(x, y, Color.Transparent);
                    }
                }
            }

            // Blend the seam at x = 144..147 for y >= 420
            BlendSeam(card2, 145, 420, 688);

            // Clean background outside
            MakeTransparent(card2);
            card2.Save(Path.Combine(baseDir, "why-choose-page-2.png"), ImageFormat.Png);
        }

        // =========================================================================
        // CARD 3: Note 3 + Full Cushion Emerald
        // =========================================================================
        int c3W = 760;
        int c3H = 690;
        using (Bitmap card3 = new Bitmap(c3W, c3H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card3)) {
                g.Clear(Color.Transparent);
                // Draw Note 3 from img4 starting at x = 120. img4 has 2px bg at left edge, sample from x=2
                g.DrawImage(img4, new Rectangle(120, 0, 640, 690), new Rectangle(2, 0, 640, 690), GraphicsUnit.Pixel);

                // Draw Cushion Left Half from img3 (x: 560 to 678, y: 480 to 688). Width = 119
                g.DrawImage(img3, new Rectangle(2, 480, 119, 210), new Rectangle(560, 480, 119, 210), GraphicsUnit.Pixel);
            }

            // Remove any leftover paper from img3 on the left (x < 120, y < 480)
            for (int y = 0; y < c3H; y++) {
                for (int x = 0; x < 120; x++) {
                    Color c = card3.GetPixel(x, y);
                    if (y < 480 || (c.R > 80 && c.G > 80 && c.B > 80 && Math.Abs(c.R - c.G) < 20)) {
                        card3.SetPixel(x, y, Color.Transparent);
                    }
                }
            }

            BlendSeam(card3, 120, 480, 688);
            MakeTransparent(card3);
            card3.Save(Path.Combine(baseDir, "why-choose-page-3.png"), ImageFormat.Png);
        }

        // =========================================================================
        // CARD 1: Note 1 + Full Round Emerald
        // =========================================================================
        int c1W = 760;
        int c1H = 690;
        using (Bitmap card1 = new Bitmap(c1W, c1H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card1)) {
                g.Clear(Color.Transparent);
                // Draw Note 1 from img2 starting at x = 125
                g.DrawImage(img2, new Rectangle(125, 0, 635, 690), new Rectangle(0, 0, 635, 690), GraphicsUnit.Pixel);

                // Draw Round Emerald Left Half from img1 (x: 392 to 516, y: 457 to 693). Width = 125
                g.DrawImage(img1, new Rectangle(0, 450, 126, 240), new Rectangle(392, 457, 126, 240), GraphicsUnit.Pixel);
            }

            BlendSeam(card1, 125, 450, 688);
            MakeTransparent(card1);
            card1.Save(Path.Combine(baseDir, "why-choose-page-1.png"), ImageFormat.Png);
        }

        img1.Dispose(); img2.Dispose(); img3.Dispose(); img4.Dispose();
        Console.WriteLine("PerfectNotesV2 complete!");
    }

    private static void BlendSeam(Bitmap bmp, int seamX, int yMin, int yMax) {
        for (int y = yMin; y <= yMax; y++) {
            Color cLeft = bmp.GetPixel(seamX - 1, y);
            Color cRight = bmp.GetPixel(seamX + 1, y);
            if (cLeft.A > 0 && cRight.A > 0) {
                // If it's in the gem area, average across seam
                int avgR = (cLeft.R + cRight.R) / 2;
                int avgG = (cLeft.G + cRight.G) / 2;
                int avgB = (cLeft.B + cRight.B) / 2;
                bmp.SetPixel(seamX, y, Color.FromArgb(255, avgR, avgG, avgB));
            }
        }
    }

    private static void MakeTransparent(Bitmap bmp) {
        int w = bmp.Width;
        int h = bmp.Height;
        Rectangle rect = new Rectangle(0, 0, w, h);
        BitmapData bd = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int totalBytes = Math.Abs(bd.Stride) * h;
        byte[] bytes = new byte[totalBytes];
        Marshal.Copy(bd.Scan0, bytes, 0, totalBytes);

        bool[] isBg = new bool[w * h];
        Queue<int> q = new Queue<int>();

        Func<int, int, bool> isBgPixel = (x, y) => {
            int idx = y * bd.Stride + (x * 4);
            byte b = bytes[idx];
            byte g = bytes[idx + 1];
            byte r = bytes[idx + 2];
            byte a = bytes[idx + 3];
            if (a == 0) return true; // already transparent
            // Background is dark forest green:
            // R <= 22, G in [18..60], B in [18..58], |G-B| <= 10
            return (r <= 22 && g >= 18 && g <= 60 && b >= 18 && b <= 58 && Math.Abs(g - b) <= 10);
        };

        // Seed edges
        for (int x = 0; x < w; x++) {
            if (isBgPixel(x, 0)) { isBg[0 * w + x] = true; q.Enqueue(0 * w + x); }
            if (isBgPixel(x, h - 1)) { isBg[(h - 1) * w + x] = true; q.Enqueue((h - 1) * w + x); }
        }
        for (int y = 0; y < h; y++) {
            if (isBgPixel(0, y)) { isBg[y * w + 0] = true; q.Enqueue(y * w + 0); }
            if (isBgPixel(w - 1, y)) { isBg[y * w + (w - 1)] = true; q.Enqueue(y * w + (w - 1)); }
        }

        int[] dx = { 0, 0, 1, -1 };
        int[] dy = { 1, -1, 0, 0 };

        while (q.Count > 0) {
            int curr = q.Dequeue();
            int cx = curr % w;
            int cy = curr / w;

            for (int i = 0; i < 4; i++) {
                int nx = cx + dx[i];
                int ny = cy + dy[i];
                if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                    int nidx = ny * w + nx;
                    if (!isBg[nidx] && isBgPixel(nx, ny)) {
                        isBg[nidx] = true;
                        q.Enqueue(nidx);
                    }
                }
            }
        }

        // Apply
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                int idx = y * w + x;
                int bidx = y * bd.Stride + (x * 4);
                if (isBg[idx]) {
                    bytes[bidx] = 0;
                    bytes[bidx + 1] = 0;
                    bytes[bidx + 2] = 0;
                    bytes[bidx + 3] = 0;
                }
            }
        }

        Marshal.Copy(bytes, 0, bd.Scan0, totalBytes);
        bmp.UnlockBits(bd);
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[PerfectNotesV2]::Run("c:\Users\User\OneDrive\Desktop\veloraaaa\images")
