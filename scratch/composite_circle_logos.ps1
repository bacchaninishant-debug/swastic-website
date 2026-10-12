Add-Type -AssemblyName System.Drawing

$logo = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\swastic-logo-black-transparent.png'))

# =========================================================================
# 1. Card 2: collection-aquamarine-logo.jpg (1000x1000 full-bleed)
# =========================================================================
$aquaSrc = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\collection-aquamarine.jpg'))

# The browser's object-fit: cover on 594x1024 crops a 594x594 square from center:
$cropSize = 594
$cropX = 0
$cropY = [int](($aquaSrc.Height - $cropSize) / 2) # 215

# We create a pristine 1000x1000 square
$targetSize = 1000
$aquaFinal = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
$gAqua = [System.Drawing.Graphics]::FromImage($aquaFinal)
$gAqua.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gAqua.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gAqua.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Draw the aquamarine photo 100% FULL BLEED (fills entire 1000x1000 square, NO borders!)
$srcRectAqua = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropSize, $cropSize)
$destRectAqua = New-Object System.Drawing.Rectangle(0, 0, $targetSize, $targetSize)
$gAqua.DrawImage($aquaSrc, $destRectAqua, $srcRectAqua, [System.Drawing.GraphicsUnit]::Pixel)

# Overlay the black Swastic logo in the top white velvet area (where user drew Circle 2)
# In 1000x1000, let's size the logo to width 270 (matching Card 1 & Card 4 proportions)
$logoW = 270
$logoH = [int]($logo.Height * ($logoW / $logo.Width))
$logoX = [int](($targetSize - $logoW) / 2)
$logoY = 55 # Perfectly centered in the top white groove

$gAqua.DrawImage($logo, $logoX, $logoY, $logoW, $logoH)
$gAqua.Dispose()
$aquaSrc.Dispose()

$aquaOut = (Join-Path (Get-Location) 'images\collection-aquamarine-logo.jpg')
$aquaFinal.Save($aquaOut, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$aquaFinal.Dispose()
Write-Output "Created $aquaOut"

# =========================================================================
# 2. Card 3: collection-carvings-logo.png (1000x1000 full-bleed)
# =========================================================================
$carvSrc = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\collection-carvings.png'))

# In collection-carvings.png (510x732), center 30% crop gives a 510x510 square at y = (732 - 510) * 0.30 = 66
$cropCarvSize = 510
$cropCarvX = 0
$cropCarvY = [int]((732 - 510) * 0.30)

$carvFinal = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
$gCarv = [System.Drawing.Graphics]::FromImage($carvFinal)
$gCarv.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gCarv.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gCarv.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Draw the carvings photo 100% FULL BLEED (fills entire 1000x1000 square, NO borders!)
$srcRectCarv = New-Object System.Drawing.Rectangle($cropCarvX, $cropCarvY, $cropCarvSize, $cropCarvSize)
$destRectCarv = New-Object System.Drawing.Rectangle(0, 0, $targetSize, $targetSize)
$gCarv.DrawImage($carvSrc, $destRectCarv, $srcRectCarv, [System.Drawing.GraphicsUnit]::Pixel)

# Overlay the black Swastic logo in the top golden beige area (where user drew Circle 3)
$gCarv.DrawImage($logo, $logoX, $logoY, $logoW, $logoH)
$gCarv.Dispose()
$carvSrc.Dispose()

$carvOut = (Join-Path (Get-Location) 'images\collection-carvings-logo.png')
$carvFinal.Save($carvOut, [System.Drawing.Imaging.ImageFormat]::Png)
$carvFinal.Dispose()
Write-Output "Created $carvOut"

$logo.Dispose()
