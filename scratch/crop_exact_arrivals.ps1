Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791631271070.png"
$img = [System.Drawing.Bitmap]::FromFile($srcPath)
Write-Output "Image size: $($img.Width) x $($img.Height)"

# Find vertical boundaries (where it's white card)
# Let's inspect along y = 130 (middle) for non-white/gap pixels
$w = $img.Width
$h = $img.Height

for ($x = 0; $x -lt $w; $x += 10) {
    $c = $img.GetPixel($x, 130)
    # Output non-white regions
    # Write-Output "x=$x: R=$($c.R) G=$($c.G) B=$($c.B)"
}

# The image has 4 boxes across 1024 width:
# In media_1791631271070.png:
# Box 1 is approx x=18..254
# Box 2 is approx x=268..504
# Box 3 is approx x=518..754
# Box 4 is approx x=768..1004

$img.Dispose()
