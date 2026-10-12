Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\User\.gemini\antigravity-ide\brain\bf3c4841-c0a8-4e7a-b248-6f9122a0c9eb\.user_uploaded\media_1791629150562.png"
$img = [System.Drawing.Bitmap]::FromFile($srcPath)
Write-Host "media_1791629150562 size: $($img.Width) x $($img.Height)"
$img.Dispose()
