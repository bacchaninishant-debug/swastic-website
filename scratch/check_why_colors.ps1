Add-Type -AssemblyName System.Drawing

$files = @("why-choose-1.png", "why-choose-2.png", "why-choose-3.png", "why-choose-4.png")
foreach ($f in $files) {
    $path = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f"
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    $cTL = $bmp.GetPixel(10, 10)
    $cTR = $bmp.GetPixel($bmp.Width - 10, 10)
    $cBL = $bmp.GetPixel(10, $bmp.Height - 10)
    $cBR = $bmp.GetPixel($bmp.Width - 10, $bmp.Height - 10)
    Write-Host "$f corners: TL=(R=$($cTL.R), G=$($cTL.G), B=$($cTL.B)), TR=(R=$($cTR.R), G=$($cTR.G), B=$($cTR.B)), BL=(R=$($cBL.R), G=$($cBL.G), B=$($cBL.B)), BR=(R=$($cBR.R), G=$($cBR.G), B=$($cBR.B))"
    $bmp.Dispose()
}
