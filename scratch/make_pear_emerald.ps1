Add-Type -AssemblyName System.Drawing

function Convert-LooseToEmerald($inputPath, $outputPath) {
    $bmp = [System.Drawing.Bitmap]::FromFile($inputPath)
    $w = $bmp.Width
    $h = $bmp.Height
    $out = New-Object System.Drawing.Bitmap($w, $h)

    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $r = $c.R
            $g = $c.G
            $b = $c.B

            if ($r -gt 246 -and $g -gt 246 -and $b -gt 246) {
                $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 255, 255))
                continue
            }

            $avg = ($r + $g + $b) / 3.0

            if ($avg -gt 238) {
                $out.SetPixel($x, $y, $c)
            } else {
                $factor = $avg / 255.0
                $nr = [int][Math]::Min(255, [Math]::Max(0, ($factor * 20.0 + ($r/255.0)*30.0)))
                $ng = [int][Math]::Min(255, [Math]::Max(0, ($factor * 210.0 + ($g/255.0)*45.0)))
                $nb = [int][Math]::Min(255, [Math]::Max(0, ($factor * 110.0 + ($b/255.0)*35.0)))
                $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $nr, $ng, $nb))
            }
        }
    }

    $out.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp.Dispose()
    $out.Dispose()
    Write-Host "Created Loose Pear: $outputPath"
}

Convert-LooseToEmerald "$PSScriptRoot\..\images\diamond-blue-pear.jpg" "$PSScriptRoot\..\images\gem-emerald-pear-hd.jpg"
