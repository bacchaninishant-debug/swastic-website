Add-Type -AssemblyName System.Drawing
$bmp1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_purewhite.png')
$c00 = $bmp1.GetPixel(0,0)
$cCenter = $bmp1.GetPixel(512,512)
Write-Output "PureWhite: Corner=$c00 Center=$cCenter"
$bmp1.Dispose()

$bmp2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_green_beryl_transparent.png')
$c00_2 = $bmp2.GetPixel(0,0)
$cCenter_2 = $bmp2.GetPixel(512,512)
Write-Output "Transparent: Corner=$c00_2 Center=$cCenter_2"
$bmp2.Dispose()
