Add-Type -AssemblyName System.Drawing

$imgDir = "c:\Users\User\OneDrive\Desktop\veloraaaa\images"
$files = @(
    "product-gem-green-beryl.png",
    "product-gem-emerald.png",
    "product-gem-aquamarine.png",
    "product-gem-maxixe.png",
    "product-gem-red-beryl.png",
    "product-gem-morganite.png",
    "product-gem-goshenite-diamond.png",
    "product-gem-heliodor.png",
    "pair-paraiba-tourmaline.png",
    "pair-chrome-tourmaline-5ct.png",
    "pair-chrome-tourmaline-8ct.png",
    "pair-chrome-tourmaline-10ct.png"
)

foreach ($f in $files) {
    $p = Join-Path $imgDir $f
    $bmp = [System.Drawing.Bitmap]::FromFile($p)
    $c00 = $bmp.GetPixel(0, 0)
    $cMid = $bmp.GetPixel([int]($bmp.Width/2), [int]($bmp.Height/2))
    $cTopEdge = $bmp.GetPixel([int]($bmp.Width/2), 5)
    $cBotEdge = $bmp.GetPixel([int]($bmp.Width/2), $bmp.Height - 5)
    
    Write-Output "$f : Corner=$c00 | TopEdge=$cTopEdge | BotEdge=$cBotEdge | Center=$cMid"
    $bmp.Dispose()
}
