$csharpSource = @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class PerfectLogoReplacer
{
    public static void Process(string imagePath, string logoPath, string outputPath)
    {
        using (Bitmap bmp = new Bitmap(imagePath))
        using (Bitmap logo = new Bitmap(logoPath))
        {
            int w = bmp.Width;
            int h = bmp.Height;

            // Region 1: Diamond top icon (X: 292..322, Y: 19..36)
            // Inpaint horizontally from x=286 to x=328
            for (int y = 19; y <= 36; y++)
            {
                Color cLeft = bmp.GetPixel(286, y);
                Color cRight = bmp.GetPixel(328, y);
                for (int x = 288; x <= 326; x++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    // Check if it's text/icon line
                    if (orig.R > 45 || orig.G > 70)
                    {
                        double u = (x - 286.0) / (328.0 - 286.0);
                        int r = (int)(cLeft.R + (cRight.R - cLeft.R) * u);
                        int g = (int)(cLeft.G + (cRight.G - cLeft.G) * u);
                        int b = (int)(cLeft.B + (cRight.B - cLeft.B) * u);
                        bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                    }
                }
            }

            // Region 2: VELORA text (X: 275..342, Y: 41..57)
            // Inpaint vertically between y=38 and y=59
            for (int x = 275; x <= 342; x++)
            {
                Color cUp = bmp.GetPixel(x, 39);
                Color cDown = bmp.GetPixel(x, 59);
                for (int y = 41; y <= 57; y++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    if (orig.R > 45 || orig.G > 70)
                    {
                        double v = (y - 39.0) / (59.0 - 39.0);
                        int r = (int)(cUp.R + (cDown.R - cUp.R) * v);
                        int g = (int)(cUp.G + (cDown.G - cUp.G) * v);
                        int b = (int)(cUp.B + (cDown.B - cUp.B) * v);
                        bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                    }
                }
            }

            // Region 3: DIAMONDS text (X: 283..334, Y: 59..71)
            // Inpaint vertically between y=58 and y=73
            for (int x = 283; x <= 334; x++)
            {
                Color cUp = bmp.GetPixel(x, 58);
                Color cDown = bmp.GetPixel(x, 73);
                for (int y = 59; y <= 71; y++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    if (orig.R > 40 || orig.G > 65)
                    {
                        double v = (y - 58.0) / (73.0 - 58.0);
                        int r = (int)(cUp.R + (cDown.R - cUp.R) * v);
                        int g = (int)(cUp.G + (cDown.G - cUp.G) * v);
                        int b = (int)(cUp.B + (cDown.B - cUp.B) * v);
                        bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                    }
                }
            }

            // Draw new Swastic Exports silver foil logo
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
$out = Join-Path (Get-Location) 'scratch\swastic_promise_v2.png'

[PerfectLogoReplacer]::Process($img, $logo, $out)
Write-Output "Done! Output at $out"
