Add-Type -AssemblyName System.Drawing

# 1. Trim the silver logo to tight bounds: X=63..267, Y=25..139
$origLogo = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\swastic-logo-silver-foil.png'))
$trimW = 205
$trimH = 115
$trimmedLogo = New-Object System.Drawing.Bitmap($trimW, $trimH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gTrim = [System.Drawing.Graphics]::FromImage($trimmedLogo)
$srcRect = New-Object System.Drawing.Rectangle(63, 25, $trimW, $trimH)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $trimW, $trimH)
$gTrim.DrawImage($origLogo, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$gTrim.Dispose()
$origLogo.Dispose()

$trimmedOut = Join-Path (Get-Location) 'scratch\trimmed_silver_logo.png'
$trimmedLogo.Save($trimmedOut, [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Open velora-promise.png and clean the box lid
$base = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))
$gBase = [System.Drawing.Graphics]::FromImage($base)
$gBase.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gBase.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Clean rectangle on the box lid: X: 275..345, Y: 18..78
# In this region, replace with clean brushed texture sampled from X: 238..273 (shift by 37px to the right)
$rand = New-Object System.Random(123)
for ($y = 18; $y -le 78; $y++) {
    for ($x = 276; $x -le 345; $x++) {
        # Sample from the clean left area of the box lid
        $sampleX = $x - 36
        if ($sampleX -lt 238) { $sampleX = 238 }
        if ($sampleX -gt 274) { $sampleX = 274 }
        
        $srcPixel = $base.GetPixel($sampleX, $y)
        
        # Feather at the edges (top, bottom, left, right)
        $distLeft = $x - 276
        $distRight = 345 - $x
        $distTop = $y - 18
        $distBottom = 78 - $y
        $edgeDist = [Math]::Min([Math]::Min($distLeft, $distRight), [Math]::Min($distTop, $distBottom))
        
        $blend = [Math]::Min(1.0, $edgeDist / 4.0)
        
        # Slight lighting adjustment: right side of lid is slightly darker/warmer than left side
        # Delta between left and right is approx -3 R, -6 G, -8 B
        $xFactor = ($x - 276) / (345.0 - 276.0)
        $adjR = [int](-2 * $xFactor)
        $adjG = [int](-5 * $xFactor)
        $adjB = [int](-8 * $xFactor)
        
        $targetR = [Math]::Max(0, [Math]::Min(255, $srcPixel.R + $adjR))
        $targetG = [Math]::Max(0, [Math]::Min(255, $srcPixel.G + $adjG))
        $targetB = [Math]::Max(0, [Math]::Min(255, $srcPixel.B + $adjB))
        
        $origPixel = $base.GetPixel($x, $y)
        $finalR = [int]($origPixel.R * (1.0 - $blend) + $targetR * $blend)
        $finalG = [int]($origPixel.G * (1.0 - $blend) + $targetG * $blend)
        $finalB = [int]($origPixel.B * (1.0 - $blend) + $targetB * $blend)
        
        $base.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $finalR, $finalG, $finalB))
    }
}

# 3. Draw the new Swastic Exports silver foil logo
# Center point of box lid space: X ~ 308, Y ~ 46
$logoW = 74
$logoH = [int]($logoW * $trimH / $trimW) # ~41 px
$logoX = 308 - [int]($logoW / 2) # ~271
$logoY = 46 - [int]($logoH / 2) # ~25

# Draw with high quality bicubic interpolation
$targetLogoRect = New-Object System.Drawing.Rectangle($logoX, $logoY, $logoW, $logoH)
$gBase.DrawImage($trimmedLogo, $targetLogoRect)

$gBase.Dispose()
$trimmedLogo.Dispose()

$testOut = Join-Path (Get-Location) 'scratch\swastic_promise_test.png'
$base.Save($testOut, [System.Drawing.Imaging.ImageFormat]::Png)
$base.Dispose()

Write-Output "Generated test composite: $testOut"
