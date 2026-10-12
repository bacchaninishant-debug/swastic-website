$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;

public class CropNotes {
    public static void GenerateCards(string panoPath, string outDir) {
        byte[] bytes = File.ReadAllBytes(panoPath);
        using (MemoryStream ms = new MemoryStream(bytes))
        using (Bitmap pano = new Bitmap(ms)) {
            int h = pano.Height;

            // Note 1: Round Gem (starts at ~390) + Note 1 paper (ends at ~1165)
            // Let's clear any Gem 2 pixels on the far right (x >= 1150)
            int n1X1 = 390;
            int n1X2 = 1175;
            int n1W = n1X2 - n1X1;
            using (Bitmap card1 = new Bitmap(n1W, h, PixelFormat.Format32bppArgb)) {
                using (Graphics g = Graphics.FromImage(card1)) {
                    g.DrawImage(pano, new Rectangle(0, 0, n1W, h), new Rectangle(n1X1, 0, n1W, h), GraphicsUnit.Pixel);
                }
                // Clear any stray Gem 2 pixels on the right (x > 750 in local coordinates, which is x > 1140 in pano)
                for (int y = 400; y < h; y++) {
                    for (int x = 740; x < n1W; x++) {
                        Color c = card1.GetPixel(x, y);
                        // If it's gem green (not paper white):
                        if (c.A > 0 && !(c.R > 120 && c.G > 120 && c.B > 120)) {
                            card1.SetPixel(x, y, Color.FromArgb(0, 0, 0, 0));
                        }
                    }
                }
                card1.Save(Path.Combine(outDir, "why-choose-note-1.png"), ImageFormat.Png);
            }

            // Note 2: Pear Gem (starts at ~1050) + Note 2 paper (ends at ~1790)
            int n2X1 = 1050;
            int n2X2 = 1800;
            int n2W = n2X2 - n2X1;
            using (Bitmap card2 = new Bitmap(n2W, h, PixelFormat.Format32bppArgb)) {
                using (Graphics g = Graphics.FromImage(card2)) {
                    g.DrawImage(pano, new Rectangle(0, 0, n2W, h), new Rectangle(n2X1, 0, n2W, h), GraphicsUnit.Pixel);
                }
                // Clear any stray Gem 3 pixels on the right (x > 710 in local coords, which is x > 1760 in pano)
                for (int y = 450; y < h; y++) {
                    for (int x = 710; x < n2W; x++) {
                        Color c = card2.GetPixel(x, y);
                        if (c.A > 0 && !(c.R > 120 && c.G > 120 && c.B > 120)) {
                            card2.SetPixel(x, y, Color.FromArgb(0, 0, 0, 0));
                        }
                    }
                }
                card2.Save(Path.Combine(outDir, "why-choose-note-2.png"), ImageFormat.Png);
            }

            // Note 3: Cushion Gem (starts at ~1750) + Note 3 paper (ends at ~2490)
            int n3X1 = 1750;
            int n3X2 = 2500;
            int n3W = n3X2 - n3X1;
            using (Bitmap card3 = new Bitmap(n3W, h, PixelFormat.Format32bppArgb)) {
                using (Graphics g = Graphics.FromImage(card3)) {
                    g.DrawImage(pano, new Rectangle(0, 0, n3W, h), new Rectangle(n3X1, 0, n3W, h), GraphicsUnit.Pixel);
                }
                card3.Save(Path.Combine(outDir, "why-choose-note-3.png"), ImageFormat.Png);
            }

            Console.WriteLine("Successfully created 3 perfect note cards!");
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[CropNotes]::GenerateCards("c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_transparent.png", "c:\Users\User\OneDrive\Desktop\veloraaaa\images")
