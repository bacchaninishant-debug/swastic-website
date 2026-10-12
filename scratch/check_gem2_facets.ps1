Add-Type -AssemblyName System.Drawing

$pano = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png')

# Check Gem 2 (pear gem: x in 1080..1320, y in 450..685)
$suspectPixels = 0
$totalGemPixels = 0

for ($y = 450; $y -le 685; $y++) {
    for ($x = 1080; $x -le 1320; $x++) {
        $c = $pano.GetPixel($x, $y)
        $totalGemPixels++
        # If it looks like background:
        if ($c.R -le 14 -and $c.G -ge 28 -and $c.G -le 46 -and $c.B -ge 28 -and $c.B -le 45 -and [Math]::Abs($c.G - $c.B) -le 6) {
            $suspectPixels++
        }
    }
}

Write-Host "In Gem 2 box ($totalGemPixels total pixels): Suspect background-like pixels = $suspectPixels"

$pano.Dispose()
