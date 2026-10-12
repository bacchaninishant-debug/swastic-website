Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))
$w = $src.Width
$h = $src.Height

# We only modify the original pixels where the text/icon actually is!
# For each row y in 16..72:
# We find the clean background color on the left of the text (e.g. at x = 265)
# and clean background color on the right of the text (e.g. at x = 346)
$clean = New-Object System.Drawing.Bitmap($src)

# Define 3 specific regions:
# 1. Old diamond: y 16..38, x 290..325
# 2. Old VELORA: y 42..58, x 275..342
# 3. Old DIAMONDS: y 59..72, x 282..335

for ($y = 16; $y -le 72; $y++) {
    $cLeft = $src.GetPixel(268, $y)
    $cRight = $src.GetPixel(346, $y)
    
    # Determine x range for this y
    $inRegion = $false
    $startX = 0
    $endX = 0
    
    if ($y -ge 16 -and $y -le 38) {
        $startX = 289; $endX = 326; $inRegion = $true
    } elseif ($y -ge 39 -and $y -le 58) {
        $startX = 274; $endX = 343; $inRegion = $true
    } elseif ($y -ge 59 -and $y -le 72) {
        $startX = 281; $endX = 336; $inRegion = $true
    }
    
    if ($inRegion) {
        for ($x = $startX; $x -le $endX; $x++) {
            $u = ($x - 268) / (346.0 - 268.0)
            # Interpolate
            $targetR = [int]($cLeft.R + ($cRight.R - $cLeft.R) * $u)
            $targetG = [int]($cLeft.G + ($cRight.G - $cLeft.G) * $u)
            $targetB = [int]($cLeft.B + ($cRight.B - $cLeft.B) * $u)
            
            # Feather with distance to edge
            $distX = [Math]::Min($x - $startX, $endX - $x)
            $feather = [Math]::Min(1.0, $distX / 3.0)
            
            $orig = $src.GetPixel($x, $y)
            $finR = [int]($orig.R * (1.0 - $feather) + $targetR * $feather)
            $finG = [int]($orig.G * (1.0 - $feather) + $targetG * $feather)
            $finB = [int]($orig.B * (1.0 - $feather) + $targetB * $feather)
            
            $clean.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $finR, $finG, $finB))
        }
    }
}

# Crop this region to inspect
$crop = New-Object System.Drawing.Bitmap(110, 95)
$g = [System.Drawing.Graphics]::FromImage($crop)
$srcRect = New-Object System.Drawing.Rectangle(250, 15, 110, 95)
$destRect = New-Object System.Drawing.Rectangle(0, 0, 110, 95)
$g.DrawImage($clean, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$out = Join-Path (Get-Location) 'scratch\crop_clean_precise.png'
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
$clean.Dispose()
$src.Dispose()

Write-Output "Saved to $out"
