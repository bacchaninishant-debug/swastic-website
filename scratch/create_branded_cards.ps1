Add-Type -AssemblyName System.Drawing

$logo = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\swastic-logo-black-transparent.png'))

# -------------------------------------------------------------
# 1. Create Card 2: collection-aquamarine-branded.jpg (1000x1000)
# -------------------------------------------------------------
$aquaSrc = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\collection-aquamarine.jpg'))
$targetSize = 1000
$aquaCard = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
$gAqua = [System.Drawing.Graphics]::FromImage($aquaCard)
$gAqua.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gAqua.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gAqua.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Background: Match the luxury white/light tone of Card 1 & 4
$gAqua.Clear([System.Drawing.Color]::FromArgb(250, 249, 247))

# Draw the aquamarine image nicely in the center/lower area
# Source image is 594x1024. Let's crop/scale the oval gem beautifully:
$aquaBoxH = 750
$aquaBoxW = 750
$aquaBoxX = [int](($targetSize - $aquaBoxW) / 2)
$aquaBoxY = 210

# Draw scaled aquamarine with rounded soft corners or framed
$srcRect = New-Object System.Drawing.Rectangle(0, [int]($aquaSrc.Height * 0.15), $aquaSrc.Width, [int]($aquaSrc.Height * 0.68))
$destRect = New-Object System.Drawing.Rectangle($aquaBoxX, $aquaBoxY, $aquaBoxW, $aquaBoxH)
$gAqua.DrawImage($aquaSrc, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

# Draw black logo at top center (y: 35)
$logoTargetW = 280
$logoTargetH = [int]($logo.Height * ($logoTargetW / $logo.Width))
$logoX = [int](($targetSize - $logoTargetW) / 2)
$logoY = 40
$gAqua.DrawImage($logo, $logoX, $logoY, $logoTargetW, $logoTargetH)

$gAqua.Dispose()
$aquaSrc.Dispose()

$aquaOut = (Join-Path (Get-Location) 'images\collection-aquamarine-branded.jpg')
$aquaCard.Save($aquaOut, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$aquaCard.Dispose()
Write-Output "Saved branded aquamarine: $aquaOut"

# -------------------------------------------------------------
# 2. Create Card 3: collection-carvings-branded.png (1000x1000)
# -------------------------------------------------------------
$carvSrc = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\collection-carvings.png'))
$carvCard = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
$gCarv = [System.Drawing.Graphics]::FromImage($carvCard)
$gCarv.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gCarv.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gCarv.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Background: match the warm golden champagne background of the carvings image
$gCarv.Clear([System.Drawing.Color]::FromArgb(238, 223, 202))

# In collection-carvings.png (510x732), the green carved leaves are between y: 220 and y: 580
# Let's draw the carved leaves centered in the lower area:
$srcCarvRect = New-Object System.Drawing.Rectangle(0, 180, $carvSrc.Width, 480)
$destCarvH = 750
$destCarvW = [int]($carvSrc.Width * ($destCarvH / 480))
$destCarvX = [int](($targetSize - $destCarvW) / 2)
$destCarvY = 210
$gCarv.DrawImage($carvSrc, (New-Object System.Drawing.Rectangle($destCarvX, $destCarvY, $destCarvW, $destCarvH)), $srcCarvRect, [System.Drawing.GraphicsUnit]::Pixel)

# Draw black logo at top center (y: 40)
# Add subtle white/cream pill or directly place black logo
$gCarv.DrawImage($logo, $logoX, $logoY, $logoTargetW, $logoTargetH)

$gCarv.Dispose()
$carvSrc.Dispose()

$carvOut = (Join-Path (Get-Location) 'images\collection-carvings-branded.png')
$carvCard.Save($carvOut, [System.Drawing.Imaging.ImageFormat]::Png)
$carvCard.Dispose()
Write-Output "Saved branded carvings: $carvOut"

$logo.Dispose()
