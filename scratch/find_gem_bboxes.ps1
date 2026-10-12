Add-Type -AssemblyName System.Drawing

$files = @(
    "product-gem-green-beryl.jpg",
    "product-gem-emerald.jpg",
    "product-gem-aquamarine.jpg",
    "product-gem-maxixe.jpg",
    "product-gem-red-beryl.jpg",
    "product-gem-morganite.jpg",
    "product-gem-goshenite-diamond.jpg",
    "product-gem-heliodor.jpg"
)

foreach ($f in $files) {
    $path = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f"
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    
    # We want to find the bounding box of non-background pixels.
    # Background pixels are characterized by very low saturation (|R-G| < 8, |G-B| < 8) and high brightness (> 220)
    # Contact shadow has low saturation (|R-G| < 8, |G-B| < 8) and lower brightness (150-230)
    # The stone itself has either color saturation OR dark facets OR distinct edges.
    
    # Let's sample along horizontal line y = 512
    $minX = 1024; $maxX = 0; $minY = 1024; $maxY = 0
    
    for ($y = 100; $y -lt 924; $y += 5) {
        for ($x = 100; $x -lt 924; $x += 5) {
            $c = $bmp.GetPixel($x, $y)
            $diffRG = [Math]::Abs($c.R - $c.G)
            $diffGB = [Math]::Abs($c.G - $c.B)
            $diffRB = [Math]::Abs($c.R - $c.B)
            $maxDiff = [Math]::Max($diffRG, [Math]::Max($diffGB, $diffRB))
            $b = ($c.R + $c.G + $c.B) / 3
            
            # If colored OR dark facet (b < 180):
            if ($maxDiff -gt 15 -or $b -lt 190) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    Write-Output "$f : Gem bbox: X=[$minX, $maxX] (w=$($maxX-$minX)), Y=[$minY, $maxY] (h=$($maxY-$minY))"
    $bmp.Dispose()
}
