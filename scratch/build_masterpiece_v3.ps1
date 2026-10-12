$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public class MasterpieceV3 {

    public static Bitmap BuildCard(string origPath, string gemPath, 
                                  Point[] tapePoly, Point[] paperPoly,
                                  Rectangle gemDestRect) 
    {
        byte[] origBytes = File.ReadAllBytes(origPath);
        using (MemoryStream ms = new MemoryStream(origBytes))
        using (Bitmap orig = new Bitmap(ms)) {
            int w = orig.Width;
            int h = orig.Height;

            Bitmap result = new Bitmap(w, h, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(result)) {
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.Clear(Color.Transparent);

                // Create GraphicsPath for Tape and Paper
                using (GraphicsPath path = new GraphicsPath()) {
                    path.AddPolygon(tapePoly);
                    path.AddPolygon(paperPoly);

                    // Set clip to path so ONLY paper and tape are copied from orig
                    g.SetClip(path);
                    g.DrawImage(orig, 0, 0, w, h);
                    g.ResetClip();
                }

                // Now load HD Gem and draw it over the bottom-left corner
                using (Bitmap gem = ExtractTransparentGem(gemPath)) {
                    // Draw soft shadow under gem
                    using (GraphicsPath shadowPath = new GraphicsPath()) {
                        shadowPath.AddEllipse(gemDestRect.X + 15, gemDestRect.Y + gemDestRect.Height - 35, gemDestRect.Width - 30, 30);
                        using (PathGradientBrush pgb = new PathGradientBrush(shadowPath)) {
                            pgb.CenterColor = Color.FromArgb(140, 0, 20, 10);
                            pgb.SurroundColors = new Color[] { Color.FromArgb(0, 0, 0, 0) };
                            g.FillPath(pgb, shadowPath);
                        }
                    }

                    // Draw HD gemstone
                    g.DrawImage(gem, gemDestRect);
                }
            }

            return result;
        }
    }

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

                    if (r > 240 && g > 240 && b > 240) {
                        dBytes[bidx] = 0; dBytes[bidx+1] = 0; dBytes[bidx+2] = 0; dBytes[bidx+3] = 0;
                    } else if (r > 210 && g > 210 && b > 210) {
                        float factor = (255f - (r + g + b)/3f) / 45f;
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

    public static void Run(string baseDir) {
        // CARD 1 (Note 1)
        // Tape in img2: x ~ 315..520, y ~ 65..115
        Point[] tape1 = new Point[] {
            new Point(315, 65), new Point(520, 75), new Point(515, 120), new Point(310, 110)
        };
        // Paper in img2: x ~ 160..645, y ~ 95..630
        Point[] paper1 = new Point[] {
            new Point(165, 100), new Point(645, 120), new Point(625, 630), new Point(145, 610)
        };
        // Gem 1: Round Brilliant Cut
        // Destination: overlaps bottom-left corner of paper (x: 15..265, y: 440..690)
        Rectangle gemRect1 = new Rectangle(10, 440, 255, 255);

        using (Bitmap c1 = BuildCard(Path.Combine(baseDir, "why-choose-2-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-round-hd.jpg"), 
                                    tape1, paper1, gemRect1)) {
            c1.Save(Path.Combine(baseDir, "why-choose-card-1.png"), ImageFormat.Png);
        }

        // CARD 2 (Note 2)
        // Tape in img3: x ~ 265..470, y ~ 65..115
        Point[] tape2 = new Point[] {
            new Point(265, 65), new Point(470, 75), new Point(465, 120), new Point(260, 110)
        };
        // Paper in img3: x ~ 125..590, y ~ 95..595
        Point[] paper2 = new Point[] {
            new Point(130, 95), new Point(590, 115), new Point(570, 595), new Point(110, 575)
        };
        // Gem 2: Pear Cut
        Rectangle gemRect2 = new Rectangle(15, 410, 230, 275);

        using (Bitmap c2 = BuildCard(Path.Combine(baseDir, "why-choose-3-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-pear-hd.jpg"), 
                                    tape2, paper2, gemRect2)) {
            c2.Save(Path.Combine(baseDir, "why-choose-card-2.png"), ImageFormat.Png);
        }

        // CARD 3 (Note 3)
        // Tape in img4: x ~ 265..480, y ~ 35..85
        Point[] tape3 = new Point[] {
            new Point(265, 35), new Point(480, 45), new Point(475, 90), new Point(260, 80)
        };
        // Paper in img4: x ~ 130..610, y ~ 65..575
        Point[] paper3 = new Point[] {
            new Point(135, 65), new Point(610, 85), new Point(590, 575), new Point(115, 555)
        };
        // Gem 3: Step-Cut / Cushion
        Rectangle gemRect3 = new Rectangle(15, 420, 240, 255);

        using (Bitmap c3 = BuildCard(Path.Combine(baseDir, "why-choose-4-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-emerald-hd.jpg"), 
                                    tape3, paper3, gemRect3)) {
            c3.Save(Path.Combine(baseDir, "why-choose-card-3.png"), ImageFormat.Png);
        }

        Console.WriteLine("MasterpieceV3 completed successfully!");
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[MasterpieceV3]::Run("c:\Users\User\OneDrive\Desktop\veloraaaa\images")
