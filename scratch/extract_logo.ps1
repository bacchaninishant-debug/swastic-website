Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile((Join-Path (Get-Location) 'images\collection-color-gems.jpg'))

$cropWidth = 340
$cropHeight = 180
$cropX = [int](($img.Width - $cropWidth) / 2)
$cropY = 32

$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropWidth, $cropHeight)
$logoBmp = New-Object System.Drawing.Bitmap($cropWidth, $cropHeight)
$g = [System.Drawing.Graphics]::FromImage($logoBmp)
$g.DrawImage($img, (New-Object System.Drawing.Rectangle(0, 0, $cropWidth, $cropHeight)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$outputPath = (Join-Path (Get-Location) 'images\swastic-black-logo-extracted.png')
$logoBmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$logoBmp.Dispose()
$img.Dispose()

Write-Output "Saved perfected logo to $outputPath"
