Add-Type -AssemblyName System.Drawing

$pano = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\scratch\panorama_test.png')
$w = $pano.Width
$h = $pano.Height

# Let's test a flood fill from (0,0) to find the contiguous background!
# Any pixel reachable from (0,0) that has background color is background!
# Background color condition:
# R <= 16, G in [25..55], B in [25..50] and |G - B| <= 8.

$visited = New-Object 'bool[,]' $w, $h
$queue = New-Object 'System.Collections.Generic.Queue[System.Drawing.Point]'

function Is-BgPixel($r, $g, $b) {
    if ($r -le 16 -and $g -ge 24 -and $g -le 52 -and $b -ge 24 -and $b -le 48 -and [Math]::Abs($g - $b) -le 8) {
        return $true
    }
    return $false
}

# Start queue from borders: top border, bottom border (where not gem), left border, right border
for ($x = 0; $x -lt $w; $x++) {
    $c = $pano.GetPixel($x, 0)
    if (Is-BgPixel $c.R $c.G $c.B) {
        $visited[$x, 0] = $true
        $queue.Enqueue((New-Object System.Drawing.Point($x, 0)))
    }
}

Write-Host "Initial queue count from top row: $($queue.Count)"

# Let's count how many pixels flood fill finds
$bgCount = 0
$dx = @(0, 0, 1, -1)
$dy = @(1, -1, 0, 0)

while ($queue.Count -gt 0) {
    $pt = $queue.Dequeue()
    $bgCount++
    for ($i = 0; $i -lt 4; $i++) {
        $nx = $pt.X + $dx[$i]
        $ny = $pt.Y + $dy[$i]
        if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
            if (-not $visited[$nx, $ny]) {
                $c = $pano.GetPixel($nx, $ny)
                if (Is-BgPixel $c.R $c.G $c.B) {
                    $visited[$nx, $ny] = $true
                    $queue.Enqueue((New-Object System.Drawing.Point($nx, $ny)))
                }
            }
        }
    }
}

Write-Host "Total background pixels identified by flood fill: $bgCount (out of $($w * $h))"

$pano.Dispose()
