Add-Type -AssemblyName System.Drawing

$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')
$img4 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-4-orig.png')

# In img3, right edge is x = 679. In img4, left edge is x = 0 (or 2).
# Let's find the top facet / brightest pixel of cushion emerald in img3 right edge vs img4 left edge!
$bestDy = 0
$minDiff = 9999999

for ($dy = -30; $dy -le 30; $dy++) {
    $diff = 0
    $count = 0
    for ($y = 520; $y -le 660; $y++) {
        $y4 = $y + $dy
        if ($y4 -ge 0 -and $y4 -lt 690) {
            $c3 = $img3.GetPixel(677, $y)
            $c4 = $img4.GetPixel(3, $y4)
            # Compare G and B
            $d = [Math]::Abs($c3.G - $c4.G) + [Math]::Abs($c3.B - $c4.B) + [Math]::Abs($c3.R - $c4.R)
            $diff += $d
            $count++
        }
    }
    if ($count -gt 0 -and ($diff / $count) -lt $minDiff) {
        $minDiff = ($diff / $count)
        $bestDy = $dy
    }
}

Write-Host "Best dy for Cushion Gem (img4 Y - img3 Y): $bestDy (avg diff: $minDiff)"

# Now check Round Gem between img1 and img2
$img1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-1-orig.png')
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

$minDiff12 = 9999999
$bestDy12 = 0
for ($dy = -30; $dy -le 30; $dy++) {
    $diff = 0
    $count = 0
    for ($y = 500; $y -le 660; $y++) {
        $y2 = $y + $dy
        if ($y2 -ge 0 -and $y2 -lt 690) {
            $c1 = $img1.GetPixel(515, $y)
            $c2 = $img2.GetPixel(2, $y2)
            $d = [Math]::Abs($c1.G - $c2.G) + [Math]::Abs($c1.B - $c2.B) + [Math]::Abs($c1.R - $c2.R)
            $diff += $d
            $count++
        }
    }
    if ($count -gt 0 -and ($diff / $count) -lt $minDiff12) {
        $minDiff12 = ($diff / $count)
        $bestDy12 = $dy
    }
}

Write-Host "Best dy for Round Gem (img2 Y - img1 Y): $bestDy12 (avg diff: $minDiff12)"

$img1.Dispose(); $img2.Dispose(); $img3.Dispose(); $img4.Dispose()
