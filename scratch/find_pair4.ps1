Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791631271070.png"
$img = [System.Drawing.Bitmap]::FromFile($srcPath)

$minX = 9999; $maxX = -1; $minY = 9999; $maxY = -1
for ($x = 768; $x -lt 1024; $x++) {
    for ($y = 50; $y -lt 210; $y++) {
        $c = $img.GetPixel($x, $y)
        if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}
Write-Host "pair4 (y < 210): X=[$minX, $maxX] w=$($maxX-$minX) Y=[$minY, $maxY] h=$($maxY-$minY)"
$img.Dispose()
