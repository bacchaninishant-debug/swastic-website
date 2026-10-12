Add-Type -AssemblyName System.Drawing
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')
Write-Host "Image 2 dims: $($img2.Width) x $($img2.Height)"

$bgR = 0; $bgG = 0; $bgB = 0; $count = 0
for ($x = 0; $x -lt 50; $x += 5) {
    for ($y = 0; $y -lt 50; $y += 5) {
        $c = $img2.GetPixel($x, $y)
        $bgR += $c.R; $bgG += $c.G; $bgB += $c.B; $count++
    }
}
Write-Host "Avg BG corner: R=$($bgR/$count) G=$($bgG/$count) B=$($bgB/$count)"

# Check background sample across image outside paper and gem
$corners = @(
    @{X=10; Y=10}, @{X=700; Y=10}, @{X=10; Y=300}, @{X=700; Y=300}, @{X=350; Y=10}
)
foreach ($pt in $corners) {
    $c = $img2.GetPixel($pt.X, $pt.Y)
    Write-Host "Point ($($pt.X), $($pt.Y)): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$img2.Dispose()
