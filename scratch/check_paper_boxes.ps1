Add-Type -AssemblyName System.Drawing

$files = @("why-choose-3.png", "why-choose-4.png")
foreach ($f in $files) {
    $bmp = [System.Drawing.Bitmap]::FromFile("c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f")
    Write-Host "=== $f ($($bmp.Width)x$($bmp.Height)) ==="
    # Find bounding box of paper (where brightness > 150)
    $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
    for ($x = 0; $x -lt $bmp.Width; $x += 10) {
        for ($y = 0; $y -lt $bmp.Height; $y += 10) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.R -gt 150 -and $c.G -gt 150 -and $c.B -gt 150) {
                if ($x -lt $minX) { $minX = $x }; if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }; if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    Write-Host "Paper approximate box: X=[$minX, $maxX], Y=[$minY, $maxY]"
    $bmp.Dispose()
}
