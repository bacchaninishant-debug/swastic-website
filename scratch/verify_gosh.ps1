Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\test_goshenite_purewhite.png')
Write-Output "Corner: $($bmp.GetPixel(0,0))"
Write-Output "Top Edge: $($bmp.GetPixel(512,10))"
Write-Output "Center: $($bmp.GetPixel(512,512))"
Write-Output "Facet 1: $($bmp.GetPixel(450,480))"
Write-Output "Facet 2: $($bmp.GetPixel(550,540))"
Write-Output "Bottom Edge: $($bmp.GetPixel(512,1000))"
$bmp.Dispose()
