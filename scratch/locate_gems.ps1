Add-Type -AssemblyName System.Drawing

$files = @("why-choose-1.png", "why-choose-2.png", "why-choose-3.png", "why-choose-4.png")

foreach ($f in $files) {
    $bmp = [System.Drawing.Bitmap]::FromFile("c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f")
    Write-Host "=== Analysis of $f ($($bmp.Width)x$($bmp.Height)) ==="
    
    # Let's find green emerald pixels: G > 80 and G > R*1.5 and G > B*1.1
    $gemPixels = @()
    for ($x = 0; $x -lt $bmp.Width; $x += 5) {
        for ($y = 0; $y -lt $bmp.Height; $y += 5) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.G -gt 70 -and ($c.G -gt $c.R * 1.4) -and ($c.G -gt $c.B * 0.9)) {
                # Ensure it's not paper (paper is white)
                if ($c.R -lt 150) {
                    $gemPixels += [PSCustomObject]@{ X = $x; Y = $y; G = $c.G }
                }
            }
        }
    }
    
    # Left gem
    $leftGems = $gemPixels | Where-Object { $_.X -lt ($bmp.Width / 2) }
    # Right gem
    $rightGems = $gemPixels | Where-Object { $_.X -ge ($bmp.Width / 2) }
    
    if ($leftGems.Count -gt 0) {
        $minX = ($leftGems | Measure-Object -Property X -Minimum).Minimum
        $maxX = ($leftGems | Measure-Object -Property X -Maximum).Maximum
        $minY = ($leftGems | Measure-Object -Property Y -Minimum).Minimum
        $maxY = ($leftGems | Measure-Object -Property Y -Maximum).Maximum
        Write-Host "  Left Gem: X=[$minX, $maxX], Y=[$minY, $maxY], count=$($leftGems.Count)"
    }
    if ($rightGems.Count -gt 0) {
        $minX = ($rightGems | Measure-Object -Property X -Minimum).Minimum
        $maxX = ($rightGems | Measure-Object -Property X -Maximum).Maximum
        $minY = ($rightGems | Measure-Object -Property Y -Minimum).Minimum
        $maxY = ($rightGems | Measure-Object -Property Y -Maximum).Maximum
        Write-Host "  Right Gem: X=[$minX, $maxX], Y=[$minY, $maxY], count=$($rightGems.Count)"
    }
    
    $bmp.Dispose()
}
