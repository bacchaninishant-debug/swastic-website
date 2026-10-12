Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791631271070.png"
$img = [System.Drawing.Bitmap]::FromFile($srcPath)

$sections = @(
    @{ name = "pair1"; startX = 0; endX = 256 },
    @{ name = "pair2"; startX = 256; endX = 512 },
    @{ name = "pair3"; startX = 512; endX = 768 },
    @{ name = "pair4"; startX = 768; endX = 1024 }
)

foreach ($s in $sections) {
    $minX = 9999; $maxX = -1; $minY = 9999; $maxY = -1
    for ($x = $s.startX; $x -lt $s.endX; $x++) {
        for ($y = 0; $y -lt $img.Height; $y++) {
            $c = $img.GetPixel($x, $y)
            # A gemstone or shadow pixel has RGB not all >= 245
            # Also ignore the 'NEW' badge in top-right corner of each card (y < 45)
            if ($y -gt 50 -and ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240)) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    Write-Host "$($s.name): X=[$minX, $maxX] w=$($maxX-$minX) Y=[$minY, $maxY] h=$($maxY-$minY)"
}

$img.Dispose()
