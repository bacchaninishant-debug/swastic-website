Add-Type -AssemblyName System.Drawing

$files = @("why-choose-1.png", "why-choose-2.png", "why-choose-3.png", "why-choose-4.png")
foreach ($f in $files) {
    $path = "c:\Users\User\OneDrive\Desktop\veloraaaa\images\$f"
    $img = [System.Drawing.Image]::FromFile($path)
    Write-Host "$f : Width=$($img.Width), Height=$($img.Height)"
    $img.Dispose()
}
