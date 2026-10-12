Add-Type -AssemblyName System.Drawing

$img1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-1-orig.png')
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')
$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')
$img4 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-4-orig.png')

Write-Host "Img1: $($img1.Width)x$($img1.Height)"
Write-Host "Img2: $($img2.Width)x$($img2.Height)"
Write-Host "Img3: $($img3.Width)x$($img3.Height)"
Write-Host "Img4: $($img4.Width)x$($img4.Height)"

# Let's create a combined panorama of the bottom part to verify the seam!
$panoW = $img1.Width + $img2.Width + $img3.Width + $img4.Width
$panoH = $img1.Height
$pano = New-Object System.Drawing.Bitmap($panoW, $panoH)
$g = [System.Drawing.Graphics]::FromImage($pano)

$g.DrawImage($img1, 0, 0)
$g.DrawImage($img2, $img1.Width, 0)
$g.DrawImage($img3, $img1.Width + $img2.Width, 0)
$g.DrawImage($img4, $img1.Width + $img2.Width + $img3.Width, 0)

$g.Dispose()
$pano.Save('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png', [System.Drawing.Imaging.ImageFormat]::Png)
$pano.Dispose()

Write-Host "Panorama saved to scratch\panorama_test.png (Total width: $panoW x $panoH)"

$img1.Dispose(); $img2.Dispose(); $img3.Dispose(); $img4.Dispose()
