Add-Type -AssemblyName System.Drawing

$imgPath = Join-Path (Get-Location) 'images\velora-promise.png'
$img = [System.Drawing.Image]::FromFile($imgPath)
Write-Output "Image Size: $($img.Width) x $($img.Height)"
$img.Dispose()
