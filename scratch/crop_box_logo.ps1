Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))
# Crop around the top-right part of the blue box: x: 260 to 360, y: 40 to 140
$crop = New-Object System.Drawing.Bitmap(150, 120)
$g = [System.Drawing.Graphics]::FromImage($crop)
$srcRect = New-Object System.Drawing.Rectangle(250, 40, 150, 120)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 150, 120)
$g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$src.Dispose()

$out = Join-Path (Get-Location) 'scratch\crop_box_logo.png'
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
Write-Output "Saved crop to $out"
