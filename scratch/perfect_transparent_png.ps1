Add-Type -AssemblyName System.Drawing

$srcPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.jpg"
$destPath = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\swastic-gems-hero.png"

$src = [System.Drawing.Bitmap]::FromFile($srcPath)
$width = $src.Width
$height = $src.Height

# We want 32-bit ARGB
$dest = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

# Read all pixel colors into memory array for maximum speed
$rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
$srcData = $src.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$destData = $dest.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::WriteOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$stride = [Math]::Abs($srcData.Stride)
$totalBytes = $stride * $height
$srcBytes = New-Object byte[] $totalBytes
$destBytes = New-Object byte[] $totalBytes

[System.Runtime.InteropServices.Marshal]::Copy($srcData.Scan0, $srcBytes, 0, $totalBytes)

# Step 1: Find background mask using Breadth-First-Search (BFS) flood fill from image borders
# A pixel is considered passable background if it is very close to white:
# Min(R,G,B) >= 244 (or DiffFromWhite <= 11)
$isBg = New-Object bool[] ($width * $height)
$queueX = New-Object "System.Collections.Generic.Queue[int]"
$queueY = New-Object "System.Collections.Generic.Queue[int]"

function GetIndex($x, $y) { return $y * $width + $x }

# Seed all 4 image borders
for ($x = 0; $x -lt $width; $x++) {
    # Top border
    $queueX.Enqueue($x); $queueY.Enqueue(0)
    $isBg[($x)] = $true
    # Bottom border
    $queueX.Enqueue($x); $queueY.Enqueue($height - 1)
    $isBg[($height - 1) * $width + $x] = $true
}
for ($y = 0; $y -lt $height; $y++) {
    # Left border
    $queueX.Enqueue(0); $queueY.Enqueue($y)
    $isBg[$y * $width] = $true
    # Right border
    $queueX.Enqueue($width - 1); $queueY.Enqueue($y)
    $isBg[$y * $width + ($width - 1)] = $true
}

# BFS expansion
while ($queueX.Count -gt 0) {
    $curX = $queueX.Dequeue()
    $curY = $queueY.Dequeue()
    
    # 4 neighbors
    $neighbors = @(
        @($curX + 1, $curY),
        @($curX - 1, $curY),
        @($curX, $curY + 1),
        @($curX, $curY - 1)
    )
    
    foreach ($n in $neighbors) {
        $nx = $n[0]
        $ny = $n[1]
        if ($nx -ge 0 -and $nx -lt $width -and $ny -ge 0 -and $ny -lt $height) {
            $nIdx = $ny * $width + $nx
            if (-not $isBg[$nIdx]) {
                $byteIdx = $ny * $stride + ($nx * 4)
                $b = [int]$srcBytes[$byteIdx]
                $g = [int]$srcBytes[$byteIdx + 1]
                $r = [int]$srcBytes[$byteIdx + 2]
                
                $minVal = [Math]::Min($r, [Math]::Min($g, $b))
                # If near white background (allows shadow fringe exploration up to luminance threshold)
                if ($minVal -ge 246) {
                    $isBg[$nIdx] = $true
                    $queueX.Enqueue($nx)
                    $queueY.Enqueue($ny)
                }
            }
        }
    }
}

# Step 2: Render with smooth antialiased alpha transition
# Any pixel marked as BG has alpha = 0.
# Any pixel not marked as BG that is adjacent to BG or has high brightness gets smooth alpha falloff.
for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $idx = $y * $width + $x
        $bIdx = $y * $stride + ($x * 4)
        
        $b = [double]$srcBytes[$bIdx]
        $g = [double]$srcBytes[$bIdx + 1]
        $r = [double]$srcBytes[$bIdx + 2]
        
        # Clean up stray speckle at bottom right
        if ($x -gt 850 -and $y -gt 650) {
            $destBytes[$bIdx] = 0
            $destBytes[$bIdx + 1] = 0
            $destBytes[$bIdx + 2] = 0
            $destBytes[$bIdx + 3] = 0
            continue
        }
        
        if ($isBg[$idx]) {
            # Fully transparent background
            $destBytes[$bIdx] = 0
            $destBytes[$bIdx + 1] = 0
            $destBytes[$bIdx + 2] = 0
            $destBytes[$bIdx + 3] = 0
        } else {
            # Check if this pixel is near the background boundary to soften the drop shadow
            $minVal = [Math]::Min($r, [Math]::Min($g, $b))
            $diffFromWhite = 255.0 - $minVal
            
            # If it's a solid stone facet or text (diff > 45), keep 100% opaque!
            if ($diffFromWhite -gt 45.0) {
                $alpha = 1.0
                $unmixR = $r
                $unmixG = $g
                $unmixB = $b
            } else {
                # Subtle drop shadow or anti-aliased edge
                # Alpha scales from 0 at diff=0 to 1.0 at diff=45
                $alpha = [Math]::Max(0.0, [Math]::Min(1.0, $diffFromWhite / 35.0))
                
                # Unmultiply white
                if ($alpha -gt 0.05) {
                    $unmixR = [Math]::Max(0.0, [Math]::Min(255.0, ($r - 255.0 * (1.0 - $alpha)) / $alpha))
                    $unmixG = [Math]::Max(0.0, [Math]::Min(255.0, ($g - 255.0 * (1.0 - $alpha)) / $alpha))
                    $unmixB = [Math]::Max(0.0, [Math]::Min(255.0, ($b - 255.0 * (1.0 - $alpha)) / $alpha))
                } else {
                    $alpha = 0.0
                    $unmixR = 0.0
                    $unmixG = 0.0
                    $unmixB = 0.0
                }
            }
            
            $destBytes[$bIdx] = [byte][Math]::Round($unmixB)
            $destBytes[$bIdx + 1] = [byte][Math]::Round($unmixG)
            $destBytes[$bIdx + 2] = [byte][Math]::Round($unmixR)
            $destBytes[$bIdx + 3] = [byte][Math]::Round($alpha * 255.0)
        }
    }
}

[System.Runtime.InteropServices.Marshal]::Copy($destBytes, 0, $destData.Scan0, $totalBytes)

$src.UnlockBits($srcData)
$dest.UnlockBits($destData)

$src.Dispose()

$dest.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
$dest.Dispose()

Write-Host "Perfect transparent PNG generated at: $destPath"
