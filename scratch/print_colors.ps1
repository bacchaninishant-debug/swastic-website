Add-Type -AssemblyName System.Drawing

$crop = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'scratch\crop_exact_logo.png'))

for ($y = 20; $y -le 70; $y += 10) {
    $cClean = $crop.GetPixel(15, $y)
    $cLogo = $crop.GetPixel(55, $y) # near center
    Write-Output "y=$($y) | Clean(15, $y): R=$($cClean.R), G=$($cClean.G), B=$($cClean.B) | Logo(55, $y): R=$($cLogo.R), G=$($cLogo.G), B=$($cLogo.B)"
}
$crop.Dispose()
