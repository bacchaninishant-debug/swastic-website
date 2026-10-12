Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'scratch\crop_exact_logo.png'))
$w = $crop.Width
$h = $crop.Height

$clean = New-Object System.Drawing.Bitmap($crop)

# Detect mask of text/icon pixels
$isText = New-Object "bool[,]" $w, $h
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $crop.GetPixel($x, $y)
        # Text is in x: 34..85, y: 15..72
        if ($x -ge 34 -and $x -le 85 -and $y -ge 15 -and $y -le 72) {
            # Text pixel if R > 60 and G > 75 (letters) or R > 80 (gold letters) or diamond icon
            if (($c.R -gt 60 -and $c.G -gt 75) -or ($c.R -gt 75) -or ($c.B -gt 150 -and $c.G -gt 90)) {
                $isText[$x, $y] = $true
            }
        }
    }
}

# Dilate mask slightly (1-2 px) so anti-aliased letter edges are fully included
$dilated = New-Object "bool[,]" $w, $h
for ($y = 1; $y -lt $h - 1; $y++) {
    for ($x = 1; $x -lt $w - 1; $x++) {
        if ($isText[$x, $y] -or $isText[$x-1, $y] -or $isText[$x+1, $y] -or $isText[$x, $y-1] -or $isText[$x, $y+1]) {
            $dilated[$x, $y] = $true
        }
    }
}

# For every dilated pixel, find the closest non-dilated pixels above and below along the same column X
for ($y = 15; $y -le 72; $y++) {
    for ($x = 32; $x -le 87; $x++) {
        if ($dilated[$x, $y]) {
            # Look up
            $upColor = $null
            $upDist = 999
            for ($dy = 1; $dy -le 15; $dy++) {
                if ($y - $dy -ge 0 -and -not $dilated[$x, $y - $dy]) {
                    $upColor = $crop.GetPixel($x, $y - $dy)
                    $upDist = $dy
                    break
                }
            }
            # Look down
            $downColor = $null
            $downDist = 999
            for ($dy = 1; $dy -le 15; $dy++) {
                if ($y + $dy -lt $h -and -not $dilated[$x, $y + $dy]) {
                    $downColor = $crop.GetPixel($x, $y + $dy)
                    $downDist = $dy
                    break
                }
            }
            
            if ($upColor -ne $null -and $downColor -ne $null) {
                $totalDist = $upDist + $downDist
                $wUp = $downDist / [double]$totalDist
                $wDown = $upDist / [double]$totalDist
                $nR = [int]($upColor.R * $wUp + $downColor.R * $wDown)
                $nG = [int]($upColor.G * $wUp + $downColor.G * $wDown)
                $nB = [int]($upColor.B * $wUp + $downColor.B * $wDown)
                $clean.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $nR, $nG, $nB))
            } elseif ($upColor -ne $null) {
                $clean.SetPixel($x, $y, $upColor)
            } elseif ($downColor -ne $null) {
                $clean.SetPixel($x, $y, $downColor)
            }
        }
    }
}

$cleanOut = Join-Path (Get-Location) 'scratch\crop_perfect_clean.png'
$clean.Save($cleanOut, [System.Drawing.Imaging.ImageFormat]::Png)
$clean.Dispose()
$crop.Dispose()
Write-Output "Saved to $cleanOut"
