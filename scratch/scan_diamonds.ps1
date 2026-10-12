Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($inputPath)

# Let's sample along horizontal lines to find exact edges of left, center, right diamonds
# at Y = 390 (middle of the diamonds)
Write-Host "Scanning Y=390 across diamonds (X=350 to 650):"
for ($x = 360; $x -le 630; $x += 2) {
    $c = $bmp.GetPixel($x, 390)
    $lum = [int](0.299 * $c.R + 0.587 * $c.G + 0.114 * $c.B)
    if ($lum -lt 245) {
        Write-Host "X=$x : Lum=$lum (R=$($c.R), G=$($c.G), B=$($c.B))"
    }
}

$bmp.Dispose()
