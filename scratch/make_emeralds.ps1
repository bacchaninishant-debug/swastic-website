Add-Type -AssemblyName System.Drawing

function Convert-ToEmerald($inputPath, $outputPath) {
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

            # Check if pure white background
            if ($r -gt 248 -and $g -gt 248 -and $b -gt 248) {
                $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 255, 255))
                continue
            }

            # Luminance
            $lum = [Math]::Max($r, [Math]::Max($g, $b))
            $min = [Math]::Min($r, [Math]::Min($g, $b))
            $avg = ($r + $g + $b) / 3.0

            # Highlights retain pure white sparkle
            if ($avg -gt 235) {
                $out.SetPixel($x, $y, $c)
            } else {
                # Map to Deep Zambian Emerald Green
                # High green, subtle blue undertone, rich dark depths
                $factor = $avg / 255.0
                
                # Dark facets get deep forest green, bright facets get glowing vivid emerald
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
    Write-Host "Created Emerald stone: $outputPath ($w x $h)"
}

$shapes = @("round", "emerald", "oval", "pear", "heart", "princess")
foreach ($s in $shapes) {
    $in = "$PSScriptRoot\..\images\product-diamond-$s.jpg"
    $out = "$PSScriptRoot\..\images\gem-emerald-$s-hd.jpg"
    if (Test-Path $in) {
        Convert-ToEmerald $in $out
    }
}
