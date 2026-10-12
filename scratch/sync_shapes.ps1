$indexContent = Get-Content 'c:\Users\User\OneDrive\Desktop\veloraaaa\index.html' -Raw
$shapesContent = Get-Content 'c:\Users\User\OneDrive\Desktop\veloraaaa\shapes.html' -Raw

$startTag = '        <!-- Product Grid: 4 GIA Certified Loose Gemstones -->'
$endTag = '        </div>' + [Environment]::NewLine + [Environment]::NewLine + '        <div class="products-view-all-row">'

# Get the new grid block from index.html
$idxStart = $indexContent.IndexOf('        <!-- Product Grid: 8 GIA Certified Loose Gemstones & Diamonds -->')
$idxEnd = $indexContent.IndexOf('        <div class="products-view-all-row">')
$newGrid = $indexContent.Substring($idxStart, $idxEnd - $idxStart)

$shpStart = $shapesContent.IndexOf('        <!-- Product Grid: 4 GIA Certified Loose Gemstones -->')
$shpEnd = $shapesContent.IndexOf('        <div class="products-view-all-row">')

if ($shpStart -ge 0 -and $shpEnd -gt $shpStart) {
    $updatedShapes = $shapesContent.Substring(0, $shpStart) + $newGrid + $shapesContent.Substring($shpEnd)
    Set-Content 'c:\Users\User\OneDrive\Desktop\veloraaaa\shapes.html' -Value $updatedShapes -NoNewline
    Write-Host "shapes.html updated successfully!"
} else {
    Write-Host "Could not find tags in shapes.html: shpStart=$shpStart, shpEnd=$shpEnd"
}
