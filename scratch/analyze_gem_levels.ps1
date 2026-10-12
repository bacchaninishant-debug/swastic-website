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
    
    # Sample corner brightness
    $c00 = $bmp.GetPixel(10, 10)
    $c10 = $bmp.GetPixel($bmp.Width - 10, 10)
    $c01 = $bmp.GetPixel(10, $bmp.Height - 10)
    $c11 = $bmp.GetPixel($bmp.Width - 10, $bmp.Height - 10)
    
    $avgBg = [int](($c00.R + $c00.G + $c00.B + $c10.R + $c10.G + $c10.B + $c01.R + $c01.G + $c01.B + $c11.R + $c11.G + $c11.B) / 12)
    
    Write-Output "File: $f | Size: $($bmp.Width)x$($bmp.Height) | Avg corner brightness: $avgBg"
    $bmp.Dispose()
}
