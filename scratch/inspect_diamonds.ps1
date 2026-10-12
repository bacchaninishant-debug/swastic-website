Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($inputPath)

# Pear diamond is around center x=512, y=360..450
$centerPix = $bmp.GetPixel(512, 400)
Write-Host "Pear diamond center (512, 400): R=$($centerPix.R), G=$($centerPix.G), B=$($centerPix.B)"

# Also let's check tiny dot near bottom right in original JPG (we noticed a tiny stray dot at (880, 680) in the original JPG!)
$dotPix = $bmp.GetPixel(880, 680)
Write-Host "Bottom right area (880, 680): R=$($dotPix.R), G=$($dotPix.G), B=$($dotPix.B)"

$bmp.Dispose()
