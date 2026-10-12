Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\swastic-logo-black-transparent.png'))
$w = $src.Width
$h = $src.Height

# We will create a silver-white luxury version
# Where black pixels in $src (alpha > 0) become silver-white:
# R=230, G=235, B=245 (with subtle sheen)
$silverBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $src.GetPixel($x, $y)
        if ($c.A -gt 15) {
            # Normalize alpha
            $a = $c.A
            # Slight vertical gradient in silver foil for realistic metallic reflection
            $ratioY = $y / [double]$h
            $silverR = [int](225 + 25 * (1.0 - $ratioY))
            $silverG = [int](232 + 20 * (1.0 - $ratioY))
            $silverB = [int](245 + 10 * (1.0 - $ratioY))
            $silverBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $silverR, $silverG, $silverB))
        } else {
            $silverBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        }
    }
}

$outPath = Join-Path (Get-Location) 'images\swastic-logo-silver-foil.png'
$silverBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$silverBmp.Dispose()
$src.Dispose()
Write-Output "Created silver foil logo: $outPath"
