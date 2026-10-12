Add-Type -AssemblyName System.Drawing

$pano = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png')

function Get-GemBounds($minXScan, $maxXScan, $minYScan, $maxYScan) {
    $minX = 9999; $maxX = -1; $minY = 9999; $maxY = -1
    for ($y = $minYScan; $y -le $maxYScan; $y++) {
        for ($x = $minXScan; $x -le $maxXScan; $x++) {
            $c = $pano.GetPixel($x, $y)
            # Emerald pixel check
            # Bright green / emerald facet:
            # G >= 45 and (G >= R*1.2 or (G > 55 and G >= B*1.05)) and NOT background
            # Background is R in 5..12, G in 30..45, B in 30..42
            $isBg = ($c.R -le 14 -and $c.G -ge 28 -and $c.G -le 46 -and $c.B -ge 28 -and $c.B -le 45 -and [Math]::Abs($c.G - $c.B) -le 6)
            if (-not $isBg) {
                # Could be gem or paper or tape
                # Gems in bottom region (y > 400) where G is predominant or very bright highlight
                if ($c.G -ge 40 -and ($c.G -ge $c.R * 1.15 -or ($c.G -gt 55 -and $c.G -ge $c.B * 1.05))) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
    }
    return @{ MinX=$minX; MaxX=$maxX; MinY=$minY; MaxY=$maxY }
}

$gem1 = Get-GemBounds 350 700 450 689
Write-Host "Gem 1 (around seam 517): X = $($gem1.MinX) .. $($gem1.MaxX), Y = $($gem1.MinY) .. $($gem1.MaxY) (W=$($gem1.MaxX - $gem1.MinX), H=$($gem1.MaxY - $gem1.MinY))"

$gem2 = Get-GemBounds 1050 1350 420 689
Write-Host "Gem 2 (around seam 1197): X = $($gem2.MinX) .. $($gem2.MaxX), Y = $($gem2.MinY) .. $($gem2.MaxY) (W=$($gem2.MaxX - $gem2.MinX), H=$($gem2.MaxY - $gem2.MinY))"

$gem3 = Get-GemBounds 1750 2050 480 689
Write-Host "Gem 3 (around seam 1877): X = $($gem3.MinX) .. $($gem3.MaxX), Y = $($gem3.MinY) .. $($gem3.MaxY) (W=$($gem3.MaxX - $gem3.MinX), H=$($gem3.MaxY - $gem3.MinY))"

$pano.Dispose()
