$csharpSource = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class PerfectReplacerFinalV2
{
    public static void Process(string originalPath, string logoPath, string[] outputPaths)
    {
        byte[] imgBytes = File.ReadAllBytes(originalPath);
        using (MemoryStream ms = new MemoryStream(imgBytes))
        using (Bitmap bmp = new Bitmap(ms))
        using (Bitmap logo = new Bitmap(logoPath))
        {
            int w = bmp.Width;
            int h = bmp.Height;

            // Region 1: Diamond top icon (X: 288..328, Y: 17..37)
            // Inpaint horizontally from clean column x=284 to clean column x=332
            for (int y = 17; y <= 37; y++)
            {
                Color cLeft = bmp.GetPixel(284, y);
                Color cRight = bmp.GetPixel(332, y);
                for (int x = 286; x <= 330; x++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    if (orig.R > 42 || orig.G > 68)
                    {
                        double u = (x - 284.0) / (332.0 - 284.0);
                        int r = (int)(cLeft.R + (cRight.R - cLeft.R) * u);
                        int g = (int)(cLeft.G + (cRight.G - cLeft.G) * u);
                        int b = (int)(cLeft.B + (cRight.B - cLeft.B) * u);
                        bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                    }
                }
            }

            // Region 2: VELORA text (X: 272..345, Y: 39..58)
            // Inpaint vertically between clean row y=38 and clean row y=59
            for (int x = 272; x <= 345; x++)
            {
                Color cUp = bmp.GetPixel(x, 38);
                Color cDown = bmp.GetPixel(x, 59);
                for (int y = 39; y <= 58; y++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    if (orig.R > 42 || orig.G > 68)
                    {
                        double v = (y - 38.0) / (59.0 - 38.0);
                        int r = (int)(cUp.R + (cDown.R - cUp.R) * v);
                        int g = (int)(cUp.G + (cDown.G - cUp.G) * v);
                        int b = (int)(cUp.B + (cDown.B - cUp.B) * v);
                        bmp.SetPixel(x, y, Color.FromArgb(255, r, g, b));
                    }
                }
            }

            // Region 3: DIAMONDS text (X: 278..342, Y: 59..73)
            // Inpaint vertically between clean row y=58 and clean row y=74
            for (int x = 278; x <= 342; x++)
            {
                Color cUp = bmp.GetPixel(x, 58);
                Color cDown = bmp.GetPixel(x, 74);
                for (int y = 59; y <= 73; y++)
                {
                    Color orig = bmp.GetPixel(x, y);
                    if (orig.R > 38 || orig.G > 62)
                    {
                        double v = (y - 58.0) / (74.0 - 58.0);
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

            string tempFile = Path.Combine(Path.GetTempPath(), "swastic_promise_temp.png");
            bmp.Save(tempFile, ImageFormat.Png);

            foreach (string outPath in outputPaths)
            {
                File.Copy(tempFile, outPath, true);
            }

            File.Delete(tempFile);
        }
    }
}
"@

Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies System.Drawing

$img = Join-Path (Get-Location) 'images\velora-promise.png'
$logo = Join-Path (Get-Location) 'scratch\trimmed_silver_logo.png'

$out1 = Join-Path (Get-Location) 'images\swastic-promise-hero.png'
$out2 = Join-Path (Get-Location) 'images\velora-promise.png'
$out3 = Join-Path (Get-Location) 'shopify\assets\velora-promise.png'

[PerfectReplacerFinalV2]::Process($img, $logo, @($out1, $out2, $out3))
Write-Output "Successfully updated all promise images!"
