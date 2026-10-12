Add-Type -AssemblyName System.Drawing

function Process-GemPair {
    param(
        [string]$srcPath,
        [string]$outPath,
        [double]$scale,
        [int]$cropMinX,
        [int]$cropMaxX,
        [int]$cropMinY,
        [int]$cropMaxY,
        [int]$targetYCenter = 300
    )

    $src = [System.Drawing.Bitmap]::FromFile($srcPath)
    
    # 1. Clean background of src bitmap
    $w = $src.Width
    $h = $src.Height
    $cleaned = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $p = $src.GetPixel($x, $y)
            $r = $p.R; $g = $p.G; $b = $p.B
            $minVal = [Math]::Min($r, [Math]::Min($g, $b))
            $maxVal = [Math]::Max($r, [Math]::Max($g, $b))
            $diff = $maxVal - $minVal

            # If it's near white background:
            # Low saturation (diff <= 10) and bright (minVal >= 244)
            if ($diff -le 10 -and $minVal -ge 244) {
                $cleaned.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 255, 255))
            } elseif ($diff -le 6 -and $minVal -ge 225) {
                # Smooth shadow falloff to pure white
                # map minVal from 225..244 to minVal..255
                $factor = ($minVal - 225.0) / 19.0
                $newR = [Math]::Min(255, [int]($r + (255 - $r) * $factor))
                $newG = [Math]::Min(255, [int]($g + (255 - $g) * $factor))
                $newB = [Math]::Min(255, [int]($b + (255 - $b) * $factor))
                $cleaned.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $newR, $newG, $newB))
            } else {
                $cleaned.SetPixel($x, $y, $p)
            }
        }
    }

    # 2. Crop to the content bounding box with a margin for shadow
    $contentW = $cropMaxX - $cropMinX
    $contentH = $cropMaxY - $cropMinY

    # 3. Create 600x600 canvas
    $canvas = New-Object System.Drawing.Bitmap(600, 600, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.Clear([System.Drawing.Color]::White)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    $destW = [int]($contentW * $scale)
    $destH = [int]($contentH * $scale)
    $destX = [int]((600 - $destW) / 2)
    $destY = [int]($targetYCenter - ($destH / 2))

    $srcRect = New-Object System.Drawing.Rectangle($cropMinX, $cropMinY, $contentW, $contentH)
    $destRect = New-Object System.Drawing.Rectangle($destX, $destY, $destW, $destH)

    $g.DrawImage($cleaned, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    $canvas.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
    $cleaned.Dispose()
    $src.Dispose()
    Write-Output "Successfully saved $outPath"
}

# Image 1 (Light Blue Baguette):
Process-GemPair `
    -srcPath "C:\Users\User\.gemini\antigravity-ide\brain\7a84410a-51b7-4a86-af80-2939e2361a74\.user_uploaded\media_1791779320776.png" `
    -outPath "c:\Users\User\OneDrive\Desktop\veloraaaa\images\pair-aquamarine-baguette.png" `
    -scale 1.35 `
    -cropMinX 50 `
    -cropMaxX 370 `
    -cropMinY 165 `
    -cropMaxY 285 `
    -targetYCenter 300

# Image 2 (Orange Cushion):
Process-GemPair `
    -srcPath "C:\Users\User\.gemini\antigravity-ide\brain\7a84410a-51b7-4a86-af80-2939e2361a74\.user_uploaded\media_1791779404999.png" `
    -outPath "c:\Users\User\OneDrive\Desktop\veloraaaa\images\pair-spessartite-garnet-cushion.png" `
    -scale 1.30 `
    -cropMinX 55 `
    -cropMaxX 365 `
    -cropMinY 95 `
    -cropMaxY 235 `
    -targetYCenter 300
