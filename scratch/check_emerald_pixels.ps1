Add-Type -AssemblyName System.Drawing

$f = "why-choose-2.png"
$bmp = [System.Drawing.Bitmap]::FromFile("c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f")

# Bottom-left emerald is in range x: 0..180, y: 380..686
$minG = 255
$darkestPix = $null

for ($x = 0; $x -lt 150; $x += 2) {
    for ($y = 400; $y -lt $bmp.Height; $y += 2) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.G -lt $minG) {
            $minG = $c.G
            $darkestPix = $c
        }
    }
}

Write-Host "Darkest pixel in BL emerald of $f : R=$($darkestPix.R), G=$($darkestPix.G), B=$($darkestPix.B)"
$bmp.Dispose()
