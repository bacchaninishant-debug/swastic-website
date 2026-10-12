Add-Type -AssemblyName System.Drawing
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

Write-Host "Width=$($img2.Width), Height=$($img2.Height)"

# In Image 2, the left emerald is around bottom-left. Let's find its bounding box and color distribution.
# Let's inspect along columns from x=0 to 250, and rows from y=400 to 689
$minX = 999; $maxX = -1; $minY = 999; $maxY = -1
for ($y = 400; $y -lt $img2.Height; $y++) {
    for ($x = 0; $x -lt 250; $x++) {
        $c = $img2.GetPixel($x, $y)
        # What distinguishes emerald from dark green background?
        # Emerald facets have brilliant green (G > 60, G > R*1.3, or bright highlights R,G,B > 80, or very bright green G > 100)
        # But emerald also has dark facets!
    }
}

# Let's inspect rows around y=500 to y=680, looking at pixel colors from x=0 to x=220
for ($y = 450; $y -le 650; $y += 30) {
    Write-Host "--- Row y=$y ---"
    $samples = @()
    for ($x = 0; $x -le 220; $x += 20) {
        $c = $img2.GetPixel($x, $y)
        $samples += "($x): R=$($c.R),G=$($c.G),B=$($c.B)"
    }
    Write-Host ($samples -join " | ")
}

$img2.Dispose()
