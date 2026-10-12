Add-Type -AssemblyName System.Drawing

function Make-TransparentPNG($inputPath, $outputPath, $targetSize = 120) {
    $bmp = [System.Drawing.Bitmap]::FromFile($inputPath)
    $w = $bmp.Width
    $h = $bmp.Height
    
    $out = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $r = $c.R
            $g = $c.G
            $b = $c.B

            # White background removal
            if ($r -gt 242 -and $g -gt 242 -and $b -gt 242) {
                $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            } elseif ($r -gt 225 -and $g -gt 225 -and $b -gt 225) {
                # Feather edge
                $alpha = [int](255 * (242 - ($r + $g + $b)/3.0) / 17.0)
                $alpha = [Math]::Max(0, [Math]::Min(255, $alpha))
                $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b))
            } else {
                $out.SetPixel($x, $y, $c)
            }
        }
    }

    # Resize to targetSize x targetSize
    $thumb = New-Object System.Drawing.Bitmap($targetSize, $targetSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($thumb)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($out, 0, 0, $targetSize, $targetSize)
    $g.Dispose()

    $thumb.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $out.Dispose()
    $thumb.Dispose()
    Write-Host "Saved transparent PNG: $outputPath"
}

$shapes = @("round", "emerald", "oval", "pear", "heart")
foreach ($s in $shapes) {
    $in = "$PSScriptRoot\..\images\gem-emerald-$s-hd.jpg"
    $out = "$PSScriptRoot\..\images\gem-emerald-$s-thumb.png"
    if (Test-Path $in) {
        Make-TransparentPNG $in $out 120
    }
}
