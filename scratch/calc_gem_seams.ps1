Add-Type -AssemblyName System.Drawing

$img1 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-1-orig.png')
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')
$img3 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-3-orig.png')
$img4 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-4-orig.png')

Write-Host "Img 1: $($img1.Width) x $($img1.Height)"
Write-Host "Img 2: $($img2.Width) x $($img2.Height)"
Write-Host "Img 3: $($img3.Width) x $($img3.Height)"
Write-Host "Img 4: $($img4.Width) x $($img4.Height)"

# Note 2 (from Img3 + left half of pear from Img2)
# In Img2, seam is at right edge (x = 679). Let's see how many pixels the pear extends leftwards from 679.
# From our find_gems scan: Gem 2 was X = 1050 .. 1350 in panorama.
# Seam between Img2 and Img3 in panorama was at X = 517 + 680 = 1197.
# So in Img2, pear gem is from X = 1050 - 517 = 533 to 679 (width = 147 px).
# In Img3, pear gem is from X = 0 to 1350 - 1197 = 153 px.
# Total width of Pear Gem = 147 + 153 = 300 px! Perfect!

# Gem 3 (from Img4 + left half from Img3):
# In panorama, seam between Img3 and Img4 is at X = 1197 + 680 = 1877.
# Gem 3 is X = 1757 .. 2050.
# In Img3, gem 3 left half is X = 1757 - 1197 = 560 to 679 (width = 120 px).
# In Img4, gem 3 right half is X = 0 to 2050 - 1877 = 173 px.
# Total width of Gem 3 = 120 + 173 = 293 px! Perfect!

# Gem 1 (from Img2 + left half from Img1):
# Seam between Img1 and Img2 in panorama is at X = 517.
# Gem 1 is X = 392 .. 700.
# In Img1, gem 1 left half is X = 392 to 516 (width = 125 px).
# In Img2, gem 1 right half is X = 0 to 700 - 517 = 183 px.
# Total width of Gem 1 = 125 + 183 = 308 px! Perfect!

$img1.Dispose(); $img2.Dispose(); $img3.Dispose(); $img4.Dispose()
