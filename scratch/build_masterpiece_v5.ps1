$csharp = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;

public class MasterpieceV5 {

    public static Bitmap BuildCard(string origPath, string gemPath, 
                                  Point[] tapePoly, Point[] paperPoly,
                                  Rectangle gemDestRect,
                                  Rectangle oldGemCleanRect) 
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

                // Create path for Tape & Paper
                using (GraphicsPath path = new GraphicsPath()) {
                    path.AddPolygon(tapePoly);
                    path.AddPolygon(paperPoly);

                    g.SetClip(path);
                    g.DrawImage(orig, 0, 0, w, h);

                    // If there's an old dark emerald facet showing behind the new gem, paint clean paper over it
                    if (!oldGemCleanRect.IsEmpty) {
                        using (SolidBrush paperBrush = new SolidBrush(Color.FromArgb(238, 238, 236))) {
                            g.FillRectangle(paperBrush, oldGemCleanRect);
                        }
                    }

                    g.ResetClip();
                }

                // Clean ONLY the outer boundary (within 15px of edges of paper/tape), NEVER touching internal text!
                // Any pixel near the polygon perimeter that has background color:
                BitmapData bd = result.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
                int totalBytes = Math.Abs(bd.Stride) * h;
                byte[] bytes = new byte[totalBytes];
                Marshal.Copy(bd.Scan0, bytes, 0, totalBytes);

                for (int y = 0; y < h; y++) {
                    for (int x = 0; x < w; x++) {
                        // Only check near the outer perimeter:
                        // Left edge x < 185, top edge y < 115, right edge x > 565, bottom edge y > 565
                        bool isPerimeter = (x < 185 || x > 565 || y < 115 || y > 565);
                        if (isPerimeter) {
                            int idx = y * bd.Stride + (x * 4);
                            byte b = bytes[idx];
                            byte gVal = bytes[idx + 1];
                            byte r = bytes[idx + 2];
                            byte a = bytes[idx + 3];

                            if (a > 0) {
                                // Background criteria on outer perimeter:
                                if (r <= 25 && gVal >= 15 && gVal <= 58 && b >= 15 && b <= 56 && Math.Abs(gVal - b) <= 10) {
                                    bytes[idx + 3] = 0; // transparent
                                }
                                // Stray green gem facets on perimeter:
                                if (x > 565 && y > 380 && gVal > 40 && gVal > r * 1.25 && !(r > 100 && gVal > 100 && b > 100)) {
                                    bytes[idx + 3] = 0;
                                }
                            }
                        }
                    }
                }

                Marshal.Copy(bytes, 0, bd.Scan0, totalBytes);
                result.UnlockBits(bd);

                // Now load HD Gem and draw it over bottom-left
                using (Bitmap gem = ExtractTransparentGem(gemPath)) {
                    // Soft drop shadow
                    using (GraphicsPath shadowPath = new GraphicsPath()) {
                        shadowPath.AddEllipse(gemDestRect.X + 22, gemDestRect.Y + gemDestRect.Height - 32, gemDestRect.Width - 44, 28);
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

                    if (r > 242 && g > 242 && b > 242) {
                        dBytes[bidx] = 0; dBytes[bidx+1] = 0; dBytes[bidx+2] = 0; dBytes[bidx+3] = 0;
                    } else if (r > 215 && g > 215 && b > 215) {
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

    public static void Run(string baseDir) {
        // CARD 1: 30+ Years + Round Gem
        Point[] tape1 = new Point[] {
            new Point(320, 70), new Point(515, 75), new Point(510, 115), new Point(315, 110)
        };
        Point[] paper1 = new Point[] {
            new Point(175, 100), new Point(640, 120), new Point(625, 625), new Point(160, 605)
        };
        Rectangle gemRect1 = new Rectangle(10, 435, 260, 260);

        using (Bitmap c1 = BuildCard(Path.Combine(baseDir, "why-choose-2-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-round-hd.jpg"), 
                                    tape1, paper1, gemRect1, Rectangle.Empty)) {
            c1.Save(Path.Combine(baseDir, "why-choose-card-1.png"), ImageFormat.Png);
        }

        // CARD 2: International Certification + Pear Gem
        Point[] tape2 = new Point[] {
            new Point(270, 70), new Point(465, 75), new Point(460, 115), new Point(265, 110)
        };
        Point[] paper2 = new Point[] {
            new Point(135, 95), new Point(585, 115), new Point(570, 590), new Point(125, 570)
        };
        Rectangle gemRect2 = new Rectangle(10, 405, 245, 285);

        using (Bitmap c2 = BuildCard(Path.Combine(baseDir, "why-choose-3-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-pear-hd.jpg"), 
                                    tape2, paper2, gemRect2, Rectangle.Empty)) {
            c2.Save(Path.Combine(baseDir, "why-choose-card-2.png"), ImageFormat.Png);
        }

        // CARD 3: Layouts & Bulk Orders + Emerald Step-Cut Gem
        Point[] tape3 = new Point[] {
            new Point(270, 38), new Point(475, 45), new Point(470, 88), new Point(265, 80)
        };
        Point[] paper3 = new Point[] {
            new Point(140, 65), new Point(605, 85), new Point(590, 570), new Point(130, 550)
        };
        Rectangle gemRect3 = new Rectangle(5, 410, 265, 275);
        Rectangle cleanOldGem3 = new Rectangle(160, 560, 80, 80);

        using (Bitmap c3 = BuildCard(Path.Combine(baseDir, "why-choose-4-orig.png"), 
                                    Path.Combine(baseDir, "gem-emerald-emerald-hd.jpg"), 
                                    tape3, paper3, gemRect3, cleanOldGem3)) {
            c3.Save(Path.Combine(baseDir, "why-choose-card-3.png"), ImageFormat.Png);
        }

        Console.WriteLine("MasterpieceV5 completed successfully!");
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies "System.Drawing.dll"
[MasterpieceV5]::Run("c:\Users\User\OneDrive\Desktop\veloraaaa\images")
