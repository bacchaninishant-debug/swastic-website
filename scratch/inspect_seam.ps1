Add-Type -AssemblyName System.Drawing

$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')
$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')

# In img2: right edge is x = 679.
# In img3: left edge is x = 0.
Write-Host "--- Seam comparison at y=550 ---"
for ($dx = -5; $dx -le -1; $dx++) {
    $c = $img2.GetPixel(680 + $dx, 550)
    Write-Host "Img2 (680+$dx): R=$($c.R), G=$($c.G), B=$($c.B)"
}
for ($dx = 0; $dx -le 5; $dx++) {
    $c = $img3.GetPixel($dx, 550)
    Write-Host "Img3 ($dx): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$img2.Dispose(); $img3.Dispose()
