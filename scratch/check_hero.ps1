Add-Type -AssemblyName System.Drawing

$hero = [System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'images\velora-promise-hero.png'))
Write-Output "Hero size: $($hero.Width) x $($hero.Height)"

# In velora-promise.png, the size is 1024x416.
# Let's see if velora-promise.png was a crop of velora-promise-hero.png!
# Let's find matching features or compare.
$hero.Dispose()
