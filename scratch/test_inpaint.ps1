Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'scratch\crop_exact_logo.png'))
$w = $crop.Width
$h = $crop.Height

$clean = New-Object System.Drawing.Bitmap($crop)

# Let's define the exact logo patch bounds
# Left edge with clean texture: x1 = 20, right edge with clean texture: x2 = 94
# Top edge: y1 = 12, bottom edge: y2 = 64
$rand = New-Object System.Random(42)

for ($y = 12; $y -le 64; $y++) {
    $cLeft = $crop.GetPixel(20, $y)
    $cRight = $crop.GetPixel(94, $y)
    
    for ($x = 22; $x -le 92; $x++) {
        # Calculate horizontal blend factor
        $u = ($x - 20) / (94.0 - 20.0)
        
        # Smooth interpolation between left and right
        # We can also add subtle noise (-2 to +2) to mimic the brushed grain
        $noise = $rand.Next(-2, 3)
        
        $r = [Math]::Min(255, [Math]::Max(0, [int]($cLeft.R + ($cRight.R - $cLeft.R) * $u + $noise)))
        $g = [Math]::Min(255, [Math]::Max(0, [int]($cLeft.G + ($cRight.G - $cLeft.G) * $u + $noise * 1.5)))
        $b = [Math]::Min(255, [Math]::Max(0, [int]($cLeft.B + ($cRight.B - $cLeft.B) * $u + $noise * 2)))
        
        # Feather the edges so it seamlessly blends with outside
        $edgeDistX = [Math]::Min($x - 22, 92 - $x)
        $edgeDistY = [Math]::Min($y - 12, 64 - $y)
        $edgeDist = [Math]::Min($edgeDistX, $edgeDistY)
        
        $alpha = [Math]::Min(1.0, $edgeDist / 5.0)
        
        $orig = $crop.GetPixel($x, $y)
        $finalR = [int]($orig.R * (1.0 - $alpha) + $r * $alpha)
        $finalG = [int]($orig.G * (1.0 - $alpha) + $g * $alpha)
        $finalB = [int]($orig.B * (1.0 - $alpha) + $b * $alpha)
        
        $clean.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $finalR, $finalG, $finalB))
    }
}

$cleanOut = Join-Path (Get-Location) 'scratch\crop_inpaint_clean.png'
$clean.Save($cleanOut, [System.Drawing.Imaging.ImageFormat]::Png)
$clean.Dispose()
$crop.Dispose()
Write-Output "Saved clean patch to $cleanOut"
