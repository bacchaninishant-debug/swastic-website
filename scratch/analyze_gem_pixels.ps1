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
    
    # Check max brightness across edges
    $edgeMax = 0
    $edgeMin = 255
    for ($x = 0; $x -lt $bmp.Width; $x += 20) {
        $cTop = $bmp.GetPixel($x, 0)
        $cBot = $bmp.GetPixel($x, $bmp.Height - 1)
        $b1 = ($cTop.R + $cTop.G + $cTop.B) / 3
        $b2 = ($cBot.R + $cBot.G + $cBot.B) / 3
        if ($b1 -gt $edgeMax) { $edgeMax = $b1 }
        if ($b1 -lt $edgeMin) { $edgeMin = $b1 }
        if ($b2 -gt $edgeMax) { $edgeMax = $b2 }
        if ($b2 -lt $edgeMin) { $edgeMin = $b2 }
    }
    
    # Check bounding box of the gem (where brightness or color saturation strongly deviates)
    # Most gems have high saturation, or darker facets
    Write-Output "$f : Edge range: min=$([int]$edgeMin), max=$([int]$edgeMax)"
    $bmp.Dispose()
}
