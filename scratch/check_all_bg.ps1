Add-Type -AssemblyName System.Drawing
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

# In why-choose-2-orig.png:
# Let's inspect the emerald on bottom left (x < 220, y > 450)
# Let's find pixels that might look like background vs pixels that are emerald
$darkGemPixels = 0
for ($y = 450; $y -lt $img2.Height; $y++) {
    for ($x = 0; $x -lt 220; $x++) {
        $c = $img2.GetPixel($x, $y)
        # Check if R <= 15 && G >= 25 && G <= 50 && B >= 25 && B <= 50
        if ($c.R -le 15 -and $c.G -ge 25 -and $c.G -le 50 -and $c.B -ge 25 -and $c.B -le 50) {
            # Could this be inside the emerald?
            # Let's check distance to emerald bright pixels
        }
    }
}

# Also let's check Image 3 and Image 4 background points
$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')
$img4 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-4-orig.png')

Write-Host "Image 3 corner (10,10): R=$($img3.GetPixel(10,10).R), G=$($img3.GetPixel(10,10).G), B=$($img3.GetPixel(10,10).B)"
Write-Host "Image 4 corner (10,10): R=$($img4.GetPixel(10,10).R), G=$($img4.GetPixel(10,10).G), B=$($img4.GetPixel(10,10).B)"

$img2.Dispose(); $img3.Dispose(); $img4.Dispose()
