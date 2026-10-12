Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))

for ($y = 0; $y -le 160; $y += 10) {
    $c = $bmp.GetPixel(300, $y)
    Write-Output "y=$($y): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()
