Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))
# Crop around x: 250..360, y: 15..110
$crop = New-Object System.Drawing.Bitmap(110, 95)
$g = [System.Drawing.Graphics]::FromImage($crop)
$srcRect = New-Object System.Drawing.Rectangle(250, 15, 110, 95)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 110, 95)
$g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$src.Dispose()

$out = Join-Path (Get-Location) 'scratch\crop_exact_logo.png'
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
Write-Output "Saved crop to $out"
