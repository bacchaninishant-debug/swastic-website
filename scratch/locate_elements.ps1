Add-Type -AssemblyName System.Drawing

$pano = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png')

Write-Host "Panorama: $($pano.Width) x $($pano.Height)"

# In panorama_test.png:
# Img1 width = 517.
# Img2 width = 680, starts at x = 517. Note 1 is in this range.
# Img3 width = 680, starts at x = 517 + 680 = 1197. Note 2 is in this range.
# Img4 width = 680, starts at x = 1197 + 680 = 1877. Note 3 is in this range.

# Let's find Emerald 1 (round emerald) bounds around x = 517 (seam between Img1 and Img2)
# Emerald 2 (pear emerald) bounds around x = 1197 (seam between Img2 and Img3)
# Emerald 3 (cushion emerald) bounds around x = 1877 (seam between Img3 and Img4)

Write-Host "Seams at: x=517 (Emerald 1), x=1197 (Emerald 2), x=1877 (Emerald 3)"

$pano.Dispose()
