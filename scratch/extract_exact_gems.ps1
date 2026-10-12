Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791631271070.png"
$img = [System.Drawing.Bitmap]::FromFile($srcPath)
$w = $img.Width
$h = $img.Height

# We know there are 4 columns. Let's find the bounding box of non-white pixels in each quadrant:
# Quadrant 1: x from 0 to 256
# Quadrant 2: x from 256 to 512
# Quadrant 3: x from 512 to 768
# Quadrant 4: x from 768 to 1024

$quads = @(
    @{ minX = 0; maxX = 256; name = "pair-paraiba-tourmaline.jpg" },
    @{ minX = 256; maxX = 512; name = "pair-chrome-tourmaline-5ct.jpg" },
    @{ minX = 512; maxX = 768; name = "pair-chrome-tourmaline-8ct.jpg" },
    @{ minX = 768; maxX = 1024; name = "pair-chrome-tourmaline-10ct.jpg" }
)

foreach ($q in $quads) {
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    for ($x = $q.minX; $x -lt $q.maxX; $x++) {
        for ($y = 0; $y -lt $h; $y++) {
            $c = $img.GetPixel($x, $y)
            # Check if not pure white / light gray background (shadows count as part of gem)
            # Pure card background is ~255,255,255 or 250+
            # If R, G, B are all > 250, it's white background
            if ($c.R -lt 248 -or $c.G -lt 248 -or $c.B -lt 248) {
                # Ignore the "NEW" badge at top right if any (y < 40)
                if ($y -gt 35) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
    }
    Write-Output "$($q.name): X=[$minX, $maxX] (w=$($maxX-$minX)), Y=[$minY, $maxY] (h=$($maxY-$minY))"
}

$img.Dispose()
