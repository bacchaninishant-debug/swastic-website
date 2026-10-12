Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($inputPath)

# Check pear diamond bounds: x: 460..545, y: 350..470
# Let's see the minimum brightness in that box
$minVal = 255
$maxVal = 0
for ($x = 460; $x -le 545; $x += 5) {
    for ($y = 350; $y -le 470; $y += 5) {
        $c = $bmp.GetPixel($x, $y)
        $lum = [int](0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B)
        if ($lum -lt $minVal) { $minVal = $lum }
        if ($lum -gt $maxVal) { $maxVal = $lum }
    }
}

Write-Host "Pear box luminance range: min=$minVal, max=$maxVal"

$bmp.Dispose()
