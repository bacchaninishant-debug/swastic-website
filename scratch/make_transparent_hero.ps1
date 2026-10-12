Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$outputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.png"

$bmp = [System.Drawing.Bitmap]::FromFile($inputPath)
$width = $bmp.Width
$height = $bmp.Height

$resultBmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

# Lock bits for fast processing
$rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
$bmpData = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$resData = $resultBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$bytesCount = [Math]::Abs($bmpData.Stride) * $height
$rgbValues = New-Object byte[] $bytesCount
$resValues = New-Object byte[] $bytesCount

[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $rgbValues, 0, $bytesCount)

# Threshold settings
# White background is typically R > 250, G > 250, B > 250
for ($i = 0; $i -lt $bytesCount; $i += 4) {
    $b = [double]$rgbValues[$i]
    $g = [double]$rgbValues[$i + 1]
    $r = [double]$rgbValues[$i + 2]
    
    # Distance from white
    $minVal = [Math]::Min($r, [Math]::Min($g, $b))
    $diffFromWhite = 255.0 - $minVal
    
    # If it's essentially pure white (within noise tolerance of JPEG, e.g. diff < 8)
    if ($diffFromWhite -le 6.0) {
        $resValues[$i] = 0
        $resValues[$i + 1] = 0
        $resValues[$i + 2] = 0
        $resValues[$i + 3] = 0 # Fully transparent
    } else {
        # Calculate alpha
        # Soft transition for shadows, solid for gems and text
        $alpha = [Math]::Min(1.0, ($diffFromWhite - 6.0) / 35.0)
        
        # If diff is large (actual stone or text), alpha is 1.0
        if ($diffFromWhite -gt 40.0) {
            $alpha = 1.0
        }
        
        # Unmultiply white to prevent white fringe/halo
        $unmixR = [Math]::Max(0.0, [Math]::Min(255.0, ($r - 255.0 * (1.0 - $alpha)) / $alpha))
        $unmixG = [Math]::Max(0.0, [Math]::Min(255.0, ($g - 255.0 * (1.0 - $alpha)) / $alpha))
        $unmixB = [Math]::Max(0.0, [Math]::Min(255.0, ($b - 255.0 * (1.0 - $alpha)) / $alpha))
        
        $resValues[$i] = [byte][Math]::Round($unmixB)
        $resValues[$i + 1] = [byte][Math]::Round($unmixG)
        $resValues[$i + 2] = [byte][Math]::Round($unmixR)
        $resValues[$i + 3] = [byte][Math]::Round($alpha * 255.0)
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($resValues, 0, $resData.Scan0, $bytesCount)

$bmp.UnlockBits($bmpData)
$resultBmp.UnlockBits($resData)

$bmp.Dispose()

$resultBmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$resultBmp.Dispose()

Write-Host "Successfully converted to transparent PNG: $outputPath"
