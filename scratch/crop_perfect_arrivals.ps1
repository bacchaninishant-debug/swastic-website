Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791631271070.png"
$src = [System.Drawing.Bitmap]::FromFile($srcPath)

$cards = @(
    @{ name = "pair-paraiba-tourmaline.jpg"; x = 16; y = 18; size = 240 },
    @{ name = "pair-chrome-tourmaline-5ct.jpg"; x = 266; y = 18; size = 240 },
    @{ name = "pair-chrome-tourmaline-8ct.jpg"; x = 516; y = 18; size = 240 },
    @{ name = "pair-chrome-tourmaline-10ct.jpg"; x = 766; y = 18; size = 240 }
)

$targetSize = 600

foreach ($c in $cards) {
    # 1. Create a 600x600 high-res canvas with pure white background
    $dest = New-Object System.Drawing.Bitmap($targetSize, $targetSize, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.Clear([System.Drawing.Color]::White)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    # Inset source rectangle by 6 pixels on each side so we don't grab the border lines
    $srcRect = New-Object System.Drawing.Rectangle(($c.x + 6), ($c.y + 6), ($c.size - 12), ($c.size - 12))
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $targetSize, $targetSize)
    $g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

    # Inpaint / cover the "NEW" badge area in the top-right corner with pure white
    $badgeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillRectangle($badgeBrush, ($targetSize - 120), 0, 120, 90)

    # Clean borders (30px on all 4 sides) with pure white
    $g.FillRectangle($badgeBrush, 0, 0, $targetSize, 30)
    $g.FillRectangle($badgeBrush, 0, ($targetSize - 30), $targetSize, 30)
    $g.FillRectangle($badgeBrush, 0, 0, 30, $targetSize)
    $g.FillRectangle($badgeBrush, ($targetSize - 30), 0, 30, $targetSize)

    $badgeBrush.Dispose()
    $g.Dispose()

    $outPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\" + $c.name
    $dest.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $dest.Dispose()
    Write-Host "Exported $($c.name) to $outPath"
}

$src.Dispose()
Write-Host "Cleaned and exported all 4 cards!"
