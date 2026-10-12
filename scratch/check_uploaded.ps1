Add-Type -AssemblyName System.Drawing
$imgPath = "C:\Users\User\.gemini\antigravity-ide\brain\a3fd8473-10dc-47ac-924a-e21de4f216c7\.user_uploaded\uploaded_media_1791772854295.png"
$img = [System.Drawing.Bitmap]::FromFile($imgPath)
Write-Output "Dimensions: $($img.Width) x $($img.Height)"
$img.Dispose()
