$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class PerfectNotesAssembler {
    public static void Run(string baseDir) {
        // Load original images
        Bitmap img1 = new Bitmap(Path.Combine(baseDir, "why-choose-1-orig.png"));
        Bitmap img2 = new Bitmap(Path.Combine(baseDir, "why-choose-2-orig.png"));
        Bitmap img3 = new Bitmap(Path.Combine(baseDir, "why-choose-3-orig.png"));
        Bitmap img4 = new Bitmap(Path.Combine(baseDir, "why-choose-4-orig.png"));

        // Helper to check if pixel is dark background
        Func<Color, bool> isBgColor = (c) => {
            // Background is dark teal/green: R <= 18, G in [22..55], B in [22..52], |G-B| <= 8
            // Also catches very dark border edges R<=15, G<=50, B<=50
            return (c.R <= 18 && c.G >= 20 && c.G <= 56 && c.B >= 20 && c.B <= 54 && Math.Abs(c.G - c.B) <= 8);
        };

        // =========================================================================
        // CARD 2 (Note 2: "INTERNATIONAL CERTIFICATION..." + Full Pear Emerald)
        // Note 2 is in img3 (680 x 690).
        // Pear emerald right half is in img3 (x: 5..155, y: 420..685).
        // Pear emerald left half is in img2 (x: 533..678, y: 420..685). (width = 146 px).
        // Img3 starts at pear center with 5px background. So offset is 146 px.
        // =========================================================================
        int card2W = 750;
        int card2H = 690;
        using (Bitmap card2 = new Bitmap(card2W, card2H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card2)) {
                g.Clear(Color.Transparent);
                
                // Draw Note 2 from img3 starting at x = 140 (so there's room for the left half of pear)
                // img3 x: 5..640 (ignore right half gem on img3)
                // Draw img3 into card2:
                // Note: img3 has 5px of background at x=0..4. By drawing img3 at x = 140, the seam is at x = 145!
                g.DrawImage(img3, new Rectangle(140, 0, 680, 690), new Rectangle(5, 0, 675, 690), GraphicsUnit.Pixel);

                // Draw pear left half from img2 (x: 533 to 678, y: 420 to 688)
                // Width = 146. Drawn at x = 0 to 146, y = 420 to 688!
                g.DrawImage(img2, new Rectangle(0, 420, 146, 270), new Rectangle(533, 420, 146, 270), GraphicsUnit.Pixel);
            }

            // Remove right-side gem half from img3 (x > 670, y > 450)
            for (int y = 450; y < card2H; y++) {
                for (int x = 650; x < card2W; x++) {
                    Color c = card2.GetPixel(x, y);
                    if (c.A > 0 && !(c.R > 120 && c.G > 120 && c.B > 120)) {
                        card2.SetPixel(x, y, Color.Transparent);
                    }
                }
            }

            // Flood-fill / transparency mask for Card 2 background
            MakeTransparent(card2);
            card2.Save(Path.Combine(baseDir, "why-choose-page-2.png"), ImageFormat.Png);
        }

        // =========================================================================
        // CARD 3 (Note 3: "LAYOUTS AND BULK ORDERS..." + Full Cushion Emerald)
        // Note 3 is in img4 (680 x 690).
        // Cushion emerald right half is in img4 (x: 2..173, y: 480..687).
        // Cushion emerald left half is in img3 (x: 560..674, y: 480..687). (width = 115 px).
        // =========================================================================
        int card3W = 750;
        int card3H = 690;
        using (Bitmap card3 = new Bitmap(card3W, card3H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card3)) {
                g.Clear(Color.Transparent);
                
                // Draw Note 3 from img4 starting at x = 115
                g.DrawImage(img4, new Rectangle(115, 0, 678, 690), new Rectangle(2, 0, 678, 690), GraphicsUnit.Pixel);

                // Draw cushion left half from img3 (x: 560 to 674, y: 480 to 688)
                g.DrawImage(img3, new Rectangle(0, 480, 115, 210), new Rectangle(560, 480, 115, 210), GraphicsUnit.Pixel);
            }

            MakeTransparent(card3);
            card3.Save(Path.Combine(baseDir, "why-choose-page-3.png"), ImageFormat.Png);
        }

        // =========================================================================
        // CARD 1 (Note 1: "30+ YEARS OF INDUSTRY TRUST..." + Full Round Emerald)
        // Note 1 is in img2 (680 x 690).
        // Round emerald right half is in img2 (x: 0..183, y: 450..686).
        // Round emerald left half is in img1 (x: 392..516, y: 450..686). (width = 125 px).
        // Note: img1 is 697 tall, img2 is 690 tall (7px offset).
        // =========================================================================
        int card1W = 750;
        int card1H = 690;
        using (Bitmap card1 = new Bitmap(card1W, card1H, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(card1)) {
                g.Clear(Color.Transparent);

                // Draw Note 1 from img2 starting at x = 125
                g.DrawImage(img2, new Rectangle(125, 0, 680, 690), new Rectangle(0, 0, 680, 690), GraphicsUnit.Pixel);

                // Draw round emerald left half from img1 (x: 392 to 516, y: 457 to 693)
                g.DrawImage(img1, new Rectangle(0, 450, 125, 237), new Rectangle(392, 457, 125, 237), GraphicsUnit.Pixel);
            }

            // Remove right-side gem half from img2 (x > 660, y > 420)
            for (int y = 420; y < card1H; y++) {
                for (int x = 650; x < card1W; x++) {
                    Color c = card1.GetPixel(x, y);
                    if (c.A > 0 && !(c.R > 120 && c.G > 120 && c.B > 120)) {
                        card1.SetPixel(x, y, Color.Transparent);
                    }
                }
            }

            MakeTransparent(card1);
            card1.Save(Path.Combine(baseDir, "why-choose-page-1.png"), ImageFormat.Png);
        }

        img1.Dispose(); img2.Dispose(); img3.Dispose(); img4.Dispose();
        Console.WriteLine("All 3 perfect note pages with complete emeralds successfully assembled!");
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
            // Background criteria:
            return (r <= 20 && g >= 18 && g <= 58 && b >= 18 && b <= 56 && Math.Abs(g - b) <= 9);
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

        // Apply transparency
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
[PerfectNotesAssembler]::Run("c:\Users\User\OneDrive\Desktop\veloraaaa\images")
