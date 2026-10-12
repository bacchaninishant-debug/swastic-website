Add-Type -AssemblyName System.Drawing

$testImgPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2.png"
$bmp = [System.Drawing.Bitmap]::FromFile($testImgPath)
$w = $bmp.Width
$h = $bmp.Height

Write-Host "Image size: $w x $h"

# Check sample points along the border to see where background is vs emerald
Write-Host "Left border (x=0) sample:"
for ($y = 0; $y -lt $h; $y += 50) {
    $c = $bmp.GetPixel(0, $y)
    Write-Host "y=$y : R=$($c.R), G=$($c.G), B=$($c.B)"
}

Write-Host "Bottom border (y=$($h-1)) sample:"
for ($x = 0; $x -lt $w; $x += 50) {
    $c = $bmp.GetPixel($x, $h - 1)
    Write-Host "x=$x : R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()
