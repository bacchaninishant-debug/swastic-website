$files = @(
    "c:\Users\User\OneDrive\Desktop\veloraaaa\index.html",
    "c:\Users\User\OneDrive\Desktop\veloraaaa\shapes.html"
)

$replacements = @{
    "images/product-gem-green-beryl.jpg" = "images/product-gem-green-beryl.png"
    "images/product-gem-emerald.jpg" = "images/product-gem-emerald.png"
    "images/product-gem-aquamarine.jpg" = "images/product-gem-aquamarine.png"
    "images/product-gem-maxixe.jpg" = "images/product-gem-maxixe.png"
    "images/product-gem-red-beryl.jpg" = "images/product-gem-red-beryl.png"
    "images/product-gem-morganite.jpg" = "images/product-gem-morganite.png"
    "images/product-gem-goshenite-diamond.jpg" = "images/product-gem-goshenite-diamond.png"
    "images/product-gem-heliodor.jpg" = "images/product-gem-heliodor.png"
    "images/pair-paraiba-tourmaline.jpg?v=exact" = "images/pair-paraiba-tourmaline.png"
    "images/pair-chrome-tourmaline-5ct.jpg?v=exact" = "images/pair-chrome-tourmaline-5ct.png"
    "images/pair-chrome-tourmaline-8ct.jpg?v=exact" = "images/pair-chrome-tourmaline-8ct.png"
    "images/pair-chrome-tourmaline-10ct.jpg?v=exact" = "images/pair-chrome-tourmaline-10ct.png"
    "images/pair-paraiba-tourmaline.jpg" = "images/pair-paraiba-tourmaline.png"
    "images/pair-chrome-tourmaline-5ct.jpg" = "images/pair-chrome-tourmaline-5ct.png"
    "images/pair-chrome-tourmaline-8ct.jpg" = "images/pair-chrome-tourmaline-8ct.png"
    "images/pair-chrome-tourmaline-10ct.jpg" = "images/pair-chrome-tourmaline-10ct.png"
}

foreach ($f in $files) {
    if (Test-Path $f) {
        $content = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
        foreach ($k in $replacements.Keys) {
            $content = $content.Replace($k, $replacements[$k])
        }
        [System.IO.File]::WriteAllText($f, $content, [System.Text.Encoding]::UTF8)
        Write-Output "Updated $f successfully!"
    }
}
