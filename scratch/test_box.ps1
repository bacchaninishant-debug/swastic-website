Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))
Write-Output "Image size: $($bmp.Width) x $($bmp.Height)"

# Check where the white/silver text pixels are within x: 250..370, y: 30..130
$minX = 9999
$maxX = 0
$minY = 9999
$maxY = 0

for ($y = 20; $y -lt 140; $y++) {
    for ($x = 240; $x -lt 380; $x++) {
        $c = $bmp.GetPixel($x, $y)
        # Text pixels have higher red/green compared to the deep blue background
        # Deep blue has high B (e.g. 100-150) and low R/G (e.g. 10-50).
        # Silver/white text has R > 100, G > 100, B > 140.
        if ($c.R -gt 90 -and $c.G -gt 90) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Detected text bounds: X=$minX..$maxX, Y=$minY..$maxY"
$bmp.Dispose()
