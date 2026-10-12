Add-Type -AssemblyName System.Drawing

$srcPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\product-gem-green-beryl.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)
$w = $bmp.Width
$h = $bmp.Height

# Create result bitmap
$out = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

# Lock bits for fast processing
$rect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
$bmpData = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$outData = $out.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$bytes = [Math]::Abs($bmpData.Stride) * $h
$rgbValues = New-Object byte[] $bytes
$outValues = New-Object byte[] $bytes

[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $rgbValues, 0, $bytes)

# Gem bbox was X=[270, 755], Y=[295, 750]
# Shadow is beneath gem Y=[700, 850], X=[250, 780]
# Outside bbox + shadow margin, everything is pure background.
# Inside background/shadow, we want white point threshold ~ 235
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $idx = ($y * $bmpData.Stride) + ($x * 4)
        $b = $rgbValues[$idx]
        $g = $rgbValues[$idx + 1]
        $r = $rgbValues[$idx + 2]
        
        # Calculate distance from gemstone center (512, 512)
        $dx = [Math]::Abs($x - 512)
        $dy = [Math]::Abs($y - 512)
        
        # Color difference / saturation
        $diffRG = [Math]::Abs([int]$r - [int]$g)
        $diffGB = [Math]::Abs([int]$g - [int]$b)
        $diffRB = [Math]::Abs([int]$r - [int]$b)
        $maxDiff = [Math]::Max($diffRG, [Math]::Max($diffGB, $diffRB))
        $bright = ([int]$r + [int]$g + [int]$b) / 3.0
        
        # Check if this pixel is inside the gem or in the background/shadow
        $isGem = $false
        if ($x -ge 260 -and $x -le 765 -and $y -ge 285 -and $y -le 760) {
            # Inside bounding box, check if it has color saturation or dark gem facet
            if ($maxDiff -ge 10 -or $bright -lt 210) {
                # Could be gem or shadow.
                # Gem in green beryl has green tint ($g > $r and $g > $b) or facet
                if ($y -lt 740 -or $maxDiff -ge 12) {
                    $isGem = $true
                }
            }
        }
        
        if ($isGem) {
            # Keep original gem pixel completely untouched
            $outValues[$idx] = $b
            $outValues[$idx + 1] = $g
            $outValues[$idx + 2] = $r
            $outValues[$idx + 3] = 255
        } else {
            # Background or shadow:
            # We remap white point. Background is ~ 238-242.
            # Any pixel with brightness >= 235 becomes 255,255,255.
            # Shadow smoothly scales up to 255.
            # If distance from center is large (> 380 px), force pure 255.
            $distFromCenter = [Math]::Sqrt($dx*$dx + $dy*$dy)
            
            # Distance fade factor (1 near stone, 0 at edge)
            $fade = 1.0
            if ($distFromCenter -gt 280) {
                $fade = [Math]::Max(0.0, (420.0 - $distFromCenter) / 140.0)
            }
            
            # White point remap:
            # Below 235, remap $v -> 255 - (255 - $v) * (255 / 235) or similar
            # If original background is ~238, the shadow darkening is (238 - $bright)
            # On pure white, that darkening is (255 - shadow_amount * 1.0)
            $bgBase = 238.0
            $shadowDarkness = [Math]::Max(0.0, ($bgBase - $bright))
            
            # Apply fade
            $finalDarkness = $shadowDarkness * $fade
            
            $newR = [Math]::Min(255, [Math]::Max(0, [int](255.0 - $finalDarkness)))
            $newG = [Math]::Min(255, [Math]::Max(0, [int](255.0 - $finalDarkness)))
            $newB = [Math]::Min(255, [Math]::Max(0, [int](255.0 - $finalDarkness)))
            
            $outValues[$idx] = [byte]$newB
            $outValues[$idx + 1] = [byte]$newG
            $outValues[$idx + 2] = [byte]$newR
            $outValues[$idx + 3] = 255
        }
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($outValues, 0, $outData.Scan0, $bytes)
$bmp.UnlockBits($bmpData)
$out.UnlockBits($outData)

$outPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_white.png"
$out.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved test image to $outPath"

$bmp.Dispose()
$out.Dispose()
