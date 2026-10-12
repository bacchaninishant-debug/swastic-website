Add-Type -AssemblyName System.Drawing
$filePath = 'C:\Users\User\.gemini\antigravity-ide\brain\d77909f7-1c79-40b2-98e9-e6e4b3318feb\.user_uploaded\media_1791606015952.png'
$img = [System.Drawing.Image]::FromFile($filePath)
Write-Host "Width: $($img.Width), Height: $($img.Height)"
$img.Dispose()
