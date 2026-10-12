Add-Type -AssemblyName System.Drawing

$files = @(
    "product-gem-green-beryl.jpg",
    "product-gem-emerald.jpg",
    "product-gem-aquamarine.jpg",
    "product-gem-maxixe.jpg",
    "product-gem-red-beryl.jpg",
    "product-gem-morganite.jpg",
    "product-gem-goshenite-diamond.jpg",
    "product-gem-heliodor.jpg",
    "pair-paraiba-tourmaline.jpg"
)

foreach ($f in $files) {
    $path = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f"
    if (Test-Path $path) {
        $bmp = [System.Drawing.Bitmap]::FromFile($path)
        $c00 = $bmp.GetPixel(0, 0)
        $cMidTop = $bmp.GetPixel([int]($bmp.Width/2), 5)
        $cCorner = $bmp.GetPixel($bmp.Width - 1, $bmp.Height - 1)
        Write-Output "$f ($($bmp.Width)x$($bmp.Height)): Corner=(R=$($c00.R),G=$($c00.G),B=$($c00.B)), MidTop=(R=$($cMidTop.R),G=$($cMidTop.G),B=$($cMidTop.B)), BottomRight=(R=$($cCorner.R),G=$($cCorner.G),B=$($cCorner.B))"
        $bmp.Dispose()
    } else {
        Write-Output "$($f) - NOT FOUND"
    }
}
