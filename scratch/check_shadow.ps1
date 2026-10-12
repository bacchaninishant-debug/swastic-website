Add-Type -AssemblyName System.Drawing
$bmp1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_purewhite.png')
# Check along center vertical below gem (x=512, y from 700 to 1000)
for ($y = 720; $y -lt 950; $y += 25) {
    $c = $bmp1.GetPixel(512, $y)
    Write-Output "y=$y : R=$($c.R), G=$($c.G), B=$($c.B)"
}
$bmp1.Dispose()
