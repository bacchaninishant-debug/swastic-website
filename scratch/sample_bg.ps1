Add-Type -AssemblyName System.Drawing
$img2 = [System.Drawing.Bitmap]::FromFile('c:\Users\User\OneDrive\Desktop\veloraaaa\images\why-choose-2-orig.png')

# Let's sample background at various coordinates:
$samples = @(
    @{X=5; Y=5}, @{X=100; Y=10}, @{X=200; Y=10}, @{X=500; Y=10}, @{X=670; Y=10},
    @{X=10; Y=200}, @{X=670; Y=200},
    @{X=10; Y=350}, @{X=670; Y=350},
    @{X=50; Y=680}, @{X=300; Y=680}, @{X=400; Y=680}, @{X=500; Y=680}
)

foreach ($s in $samples) {
    $c = $img2.GetPixel($s.X, $s.Y)
    Write-Host "BG Sample ($($s.X), $($s.Y)): R=$($c.R), G=$($c.G), B=$($c.B)"
}

$img2.Dispose()
