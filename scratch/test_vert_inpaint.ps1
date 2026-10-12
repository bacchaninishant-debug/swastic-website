Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'scratch\crop_exact_logo.png'))
$w = $crop.Width
$h = $crop.Height

$clean = New-Object System.Drawing.Bitmap($crop)

# In crop coordinates:
# Logo is between x=30..85, y=14..68
for ($iter = 0; $iter -lt 3; $iter++) {
    for ($y = 14; $y -le 68; $y++) {
        for ($x = 28; $x -le 88; $x++) {
            $c = $clean.GetPixel($x, $y)
            # Text pixel condition:
            if ($c.R -gt 55 -or $c.G -gt 78) {
                # Find clean pixel above
                $upC = $null
                for ($dy = 1; $dy -le 8; $dy++) {
                    if ($y - $dy -ge 0) {
                        $p = $clean.GetPixel($x, $y - $dy)
                        if ($p.R -le 50 -and $p.G -le 75) {
                            $upC = $p
                            break
                        }
                    }
                }
                # Find clean pixel below
                $downC = $null
                for ($dy = 1; $dy -le 8; $dy++) {
                    if ($y + $dy -lt $h) {
                        $p = $clean.GetPixel($x, $y + $dy)
                        if ($p.R -le 50 -and $p.G -le 75) {
                            $downC = $p
                            break
                        }
                    }
                }
                
                if ($upC -ne $null -and $downC -ne $null) {
                    $nR = [int](($upC.R + $downC.R) / 2)
                    $nG = [int](($upC.G + $downC.G) / 2)
                    $nB = [int](($upC.B + $downC.B) / 2)
                    $clean.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $nR, $nG, $nB))
                } elseif ($upC -ne $null) {
                    $clean.SetPixel($x, $y, $upC)
                } elseif ($downC -ne $null) {
                    $clean.SetPixel($x, $y, $downC)
                }
            }
        }
    }
}

$cleanOut = Join-Path (Get-Location) 'scratch\crop_vert_inpaint.png'
$clean.Save($cleanOut, [System.Drawing.Imaging.ImageFormat]::Png)
$clean.Dispose()
$crop.Dispose()
Write-Output "Saved vertical inpaint test to $cleanOut"
