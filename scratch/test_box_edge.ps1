Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise.png'))

for ($x = 240; $x -le 390; $x += 10) {
    $c = $bmp.GetPixel($x, 70)
    Write-Output "x=$($x): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()
