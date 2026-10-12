Add-Type -AssemblyName System.Drawing

$hero = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise-hero.png'))
$crop = New-Object System.Drawing.Bitmap(110, 95)
$g = [System.Drawing.Graphics]::FromImage($crop)
# Y offset is 160
$srcRect = New-Object System.Drawing.Rectangle(250, 175, 110, 95)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 110, 95)
$g.DrawImage($hero, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$hero.Dispose()

$out = Join-Path (Get-Location) 'scratch\crop_hero_original.png'
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
Write-Output "Saved hero crop to $out"
