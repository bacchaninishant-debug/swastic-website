Add-Type -AssemblyName System.Drawing

$inputPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($inputPath)

Write-Host "Width: $($bmp.Width), Height: $($bmp.Height)"
$corners = @(
    $bmp.GetPixel(0, 0),
    $bmp.GetPixel($bmp.Width - 1, 0),
    $bmp.GetPixel(0, $bmp.Height - 1),
    $bmp.GetPixel($bmp.Width - 1, $bmp.Height - 1)
)

foreach ($c in $corners) {
    Write-Host "Corner color: R=$($c.R), G=$($c.G), B=$($c.B)"
}

$bmp.Dispose()
