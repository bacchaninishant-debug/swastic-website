Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\swastic-black-logo-extracted.png'))
$w = $src.Width
$h = $src.Height
$transBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $src.GetPixel($x, $y)
        # Compute brightness (0 = black, 255 = pure white)
        $brightness = [int]($c.R * 0.299 + $c.G * 0.587 + $c.B * 0.114)
        if ($brightness -gt 240) {
            # Fully transparent
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        } elseif ($brightness -lt 100) {
            # Fully opaque black
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 10, 10, 10))
        } else {
            # Smooth anti-aliased alpha
            $alpha = 255 - [int](($brightness - 100) * 255 / (240 - 100))
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, 10, 10, 10))
        }
    }
}

$outPath = (Join-Path (Get-Location) 'images\swastic-logo-black-transparent.png')
$transBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$transBmp.Dispose()
$src.Dispose()
Write-Output "Created transparent logo: $outPath"
