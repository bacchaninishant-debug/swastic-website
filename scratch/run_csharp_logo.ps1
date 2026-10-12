$csharpSource = @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class LogoReplacer
{
    public static void Process(string imagePath, string logoPath, string outputPath)
    {
        using (Bitmap bmp = new Bitmap(imagePath))
        using (Bitmap logo = new Bitmap(logoPath))
        {
            int w = bmp.Width;
            int h = bmp.Height;

            bool[,] isText = new bool[w, h];

            // 1. Detect old logo pixels in region X: 275..345, Y: 15..75
            for (int y = 15; y <= 75; y++)
            {
                for (int x = 275; x <= 345; x++)
                {
                    Color c = bmp.GetPixel(x, y);
                    if (c.R > 55 || c.G > 75 || (c.B > 135 && c.R > 40))
                    {
                        isText[x, y] = true;
                    }
                }
            }

            // Dilate mask by 1 pixel to catch anti-aliased fringes
            bool[,] mask = new bool[w, h];
            for (int y = 15; y <= 75; y++)
            {
                for (int x = 275; x <= 345; x++)
                {
                    if (isText[x, y])
                    {
                        for (int dy = -1; dy <= 1; dy++)
                        {
                            for (int dx = -1; dx <= 1; dx++)
                            {
                                int nx = x + dx;
                                int ny = y + dy;
                                if (nx >= 0 && nx < w && ny >= 0 && ny < h)
                                    mask[nx, ny] = true;
                            }
                        }
                    }
                }
            }

            // 2. Inpaint mask vertically along column x
            for (int y = 15; y <= 75; y++)
            {
                for (int x = 275; x <= 345; x++)
                {
                    if (mask[x, y])
                    {
                        Color? upCol = null;
                        int upDist = 0;
                        for (int dy = 1; dy <= 20; dy++)
                        {
                            int ny = y - dy;
                            if (ny >= 0 && !mask[x, ny])
                            {
                                upCol = bmp.GetPixel(x, ny);
                                upDist = dy;
                                break;
                            }
                        }

                        Color? downCol = null;
                        int downDist = 0;
                        for (int dy = 1; dy <= 20; dy++)
                        {
                            int ny = y + dy;
                            if (ny < h && !mask[x, ny])
                            {
                                downCol = bmp.GetPixel(x, ny);
                                downDist = dy;
                                break;
                            }
                        }

                        if (upCol.HasValue && downCol.HasValue)
                        {
                            double total = upDist + downDist;
                            double wUp = downDist / total;
                            double wDown = upDist / total;
                            int r = (int)(upCol.Value.R * wUp + downCol.Value.R * wDown);
                            int g = (int)(upCol.Value.G * wUp + downCol.Value.G * wDown);
                            int b = (int)(upCol.Value.B * wUp + downCol.Value.B * wDown);
                            bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                        }
                        else if (upCol.HasValue)
                        {
                            bmp.SetPixel(x, y, upCol.Value);
                        }
                        else if (downCol.HasValue)
                        {
                            bmp.SetPixel(x, y, downCol.Value);
                        }
                    }
                }
            }

            // 3. Draw new Swastic Exports silver foil logo
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                int logoW = 76;
                int logoH = (int)(logoW * (double)logo.Height / logo.Width); // ~42px
                int logoX = 308 - (logoW / 2); // ~270
                int logoY = 46 - (logoH / 2);  // ~25

                g.DrawImage(logo, new Rectangle(logoX, logoY, logoW, logoH));
            }

            bmp.Save(outputPath, ImageFormat.Png);
        }
    }
}
"@

Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies System.Drawing

$img = Join-Path (Get-Location) 'images\velora-promise.png'
$logo = Join-Path (Get-Location) 'scratch\trimmed_silver_logo.png'
$out = Join-Path (Get-Location) 'scratch\swastic_promise_perfect.png'

[LogoReplacer]::Process($img, $logo, $out)
Write-Output "Done! Output at $out"
