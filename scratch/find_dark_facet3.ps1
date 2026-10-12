Add-Type -AssemblyName System.Drawing

$c3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-card-3.png')

# Find pixels that are dark green in the region x in [180..300], y in [500..650]
for ($y = 500; $y -le 660; $y += 5) {
    for ($x = 180; $x -le 300; $x += 5) {
        $c = $c3.GetPixel($x, $y)
        if ($c.G -gt 30 -and $c.G -gt $c.R * 1.3 -and $c.G -gt $c.B * 1.05 -and $c.A -gt 200) {
            Write-Host "Dark green at ($x, $y): R=$($c.R), G=$($c.G), B=$($c.B)"
        }
    }
}

$c3.Dispose()
