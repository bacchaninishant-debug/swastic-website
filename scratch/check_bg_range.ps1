Add-Type -AssemblyName System.Drawing

$files = @("why-choose-2.png", "why-choose-3.png", "why-choose-4.png", "why-choose-1.png")
foreach ($f in $files) {
    $path = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f"
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    
    # Sample top edge (x: 50..w-50, y: 10..50) where it's definitely the dark green background
    $minR = 255; $maxR = 0
    $minG = 255; $maxG = 0
    $minB = 255; $maxB = 0
    
    for ($x = 50; $x -lt ($bmp.Width - 50); $x += 10) {
        for ($y = 10; $y -lt 40; $y += 5) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.R -lt $minR) { $minR = $c.R }; if ($c.R -gt $maxR) { $maxR = $c.R }
            if ($c.G -lt $minG) { $minG = $c.G }; if ($c.G -gt $maxG) { $maxG = $c.G }
            if ($c.B -lt $minB) { $minB = $c.B }; if ($c.B -gt $maxB) { $maxB = $c.B }
        }
    }
    
    Write-Host "$f background range at top: R=[$minR, $maxR], G=[$minG, $maxG], B=[$minB, $maxB]"
    $bmp.Dispose()
}
