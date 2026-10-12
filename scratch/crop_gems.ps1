Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile("$PSScriptRoot\..\images\choose-shape-reel.png")

function Crop-Image($x, $y, $w, $h, $destPath) {
    $rect = New-Object System.Drawing.Rectangle($x, $y, $w, $h)
    $cropped = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($cropped)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($src, 0, 0, $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $cropped.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $cropped.Dispose()
    Write-Host "Saved $destPath ($w x $h)"
}

# 1. Round emerald (approx x: 250, y: 135, w: 75, h: 75)
Crop-Image 250 135 75 75 "$PSScriptRoot\..\images\gem-emerald-round.png"

# 2. Pear ring (approx x: 145, y: 260, w: 145, h: 90)
Crop-Image 145 260 145 90 "$PSScriptRoot\..\images\gem-emerald-pear-ring.png"

# 3. Emerald step cut (approx x: 250, y: 410, w: 75, h: 80)
Crop-Image 250 410 75 80 "$PSScriptRoot\..\images\gem-emerald-cut.png"

$src.Dispose()
