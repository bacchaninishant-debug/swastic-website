Add-Type -AssemblyName System.Drawing

# Let's inspect Note 1 (img2) round emerald at bottom left:
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

# In img2: the round emerald right half is at x = 0..190, y = 450..689.
# Let's see: x=0 is the vertical centerline of the round emerald!
# Let's check if mirroring x in 0..190 to the left (new X = 190 - x) creates a full 380px wide round emerald!
$roundW = 380
$roundH = 260
$roundGem = New-Object System.Drawing.Bitmap($roundW, $roundH)
$g = [System.Drawing.Graphics]::FromImage($roundGem)
$g.Clear([System.Drawing.Color]::Transparent)

for ($y = 0; $y -lt $roundH; $y++) {
    $srcY = 440 + $y
    if ($srcY -lt $img2.Height) {
        for ($x = 0; $x -lt 190; $x++) {
            $c = $img2.GetPixel($x, $srcY)
            # Only if it's gem color (not background)
            # Bg is R in 5..18, G in 25..55, B in 25..52, |G-B| <= 8
            $isBg = ($c.R -le 18 -and $c.G -ge 22 -and $c.G -le 55 -and $c.B -ge 22 -and $c.B -le 52 -and [Math]::Abs($c.G - $c.B) -le 8)
            if (-not $isBg -and ($c.G -ge 35 -or ($c.R -gt 50 -and $c.G -gt 50))) {
                # Right half (x = 190 + x)
                $roundGem.SetPixel(190 + $x, $y, $c)
                # Left half (mirrored: x = 190 - x)
                $roundGem.SetPixel(190 - $x, $y, $c)
            }
        }
    }
}
$g.Dispose()
$roundGem.Save('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_round_mirrored.png', [System.Drawing.Imaging.ImageFormat]::Png)
$roundGem.Dispose()
$img2.Dispose()

Write-Host "Mirrored round gem saved to scratch\test_round_mirrored.png"
