Add-Type -AssemblyName System.Drawing

$img1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-1-orig.png')
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

# Find gem bounds at x=515 in img1
$minY1 = 999; $maxY1 = -1
for ($y = 0; $y -lt $img1.Height; $y++) {
    $c = $img1.GetPixel(515, $y)
    if ($c.G -ge 50 -and ($c.G -gt $c.R * 1.2 -or $c.G -gt $c.B * 1.05)) {
        if ($y -lt $minY1) { $minY1 = $y }
        if ($y -gt $maxY1) { $maxY1 = $y }
    }
}
Write-Host "Img1 round gem at seam (x=515): Y = $minY1 .. $maxY1 (H = $($maxY1 - $minY1))"

# Find gem bounds at x=2 in img2
$minY2 = 999; $maxY2 = -1
for ($y = 0; $y -lt $img2.Height; $y++) {
    $c = $img2.GetPixel(2, $y)
    if ($c.G -ge 50 -and ($c.G -gt $c.R * 1.2 -or $c.G -gt $c.B * 1.05)) {
        if ($y -lt $minY2) { $minY2 = $y }
        if ($y -gt $maxY2) { $maxY2 = $y }
    }
}
Write-Host "Img2 round gem at seam (x=2): Y = $minY2 .. $maxY2 (H = $($maxY2 - $minY2))"

$img1.Dispose(); $img2.Dispose()
