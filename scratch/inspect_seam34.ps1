Add-Type -AssemblyName System.Drawing

$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')
$img4 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-4-orig.png')

Write-Host "--- Seam comparison at y=580 between Img3 and Img4 ---"
for ($dx = -5; $dx -le -1; $dx++) {
    $c = $img3.GetPixel(680 + $dx, 580)
    Write-Host "Img3 (680+$dx): R=$($c.R), G=$($c.G), B=$($c.B)"
}
for ($dx = 0; $dx -le 8; $dx++) {
    $c = $img4.GetPixel($dx, 580)
    Write-Host "Img4 ($dx): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$img3.Dispose(); $img4.Dispose()
