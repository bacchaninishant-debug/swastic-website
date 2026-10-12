Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png')
$w = $bmp.Width
$h = $bmp.Height

Write-Host "Panorama dimensions: $w x $h"

# Let's inspect what colors belong to background across the panorama:
# Top banner (y: 0..40 across all x) is definitely background!
$bgMaxR = 0; $bgMaxG = 0; $bgMaxB = 0
$bgMinR = 255; $bgMinG = 255; $bgMinB = 255

for ($x = 0; $x -lt $w; $x += 10) {
    for ($y = 0; $y -lt 30; $y += 5) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt $bgMaxR) { $bgMaxR = $c.R }
        if ($c.G -gt $bgMaxG) { $bgMaxG = $c.G }
        if ($c.B -gt $bgMaxB) { $bgMaxB = $c.B }
        if ($c.R -lt $bgMinR) { $bgMinR = $c.R }
        if ($c.G -lt $bgMinG) { $bgMinG = $c.G }
        if ($c.B -lt $bgMinB) { $bgMinB = $c.B }
    }
}

Write-Host "Background color range across entire top of panorama:"
Write-Host "R: $bgMinR .. $bgMaxR"
Write-Host "G: $bgMinG .. $bgMaxG"
Write-Host "B: $bgMinB .. $bgMaxB"

$bmp.Dispose()
