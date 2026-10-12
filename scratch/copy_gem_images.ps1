$brain = 'C:\Users\User\.gemini\antigravity-ide\brain\d77909f7-1c79-40b2-98e9-e6e4b3318feb'
$dest = 'c:\Users\User\OneDrive\Desktop\veloraaaa\images'

Copy-Item (Join-Path $brain 'green_beryl_gem_1791606262671.jpg') (Join-Path $dest 'product-gem-green-beryl.jpg') -Force
Copy-Item (Join-Path $brain 'emerald_stone_gem_1791606280800.jpg') (Join-Path $dest 'product-gem-emerald.jpg') -Force
Copy-Item (Join-Path $brain 'aquamarine_cushion_gem_1791606296431.jpg') (Join-Path $dest 'product-gem-aquamarine.jpg') -Force
Copy-Item (Join-Path $brain 'maxixe_blue_gem_1791606314205.jpg') (Join-Path $dest 'product-gem-maxixe.jpg') -Force
Copy-Item (Join-Path $brain 'red_beryl_gem_1791606334696.jpg') (Join-Path $dest 'product-gem-red-beryl.jpg') -Force
Copy-Item (Join-Path $brain 'morganite_pear_gem_1791606352576.jpg') (Join-Path $dest 'product-gem-morganite.jpg') -Force
Copy-Item (Join-Path $brain 'goshenite_diamond_gem_1791606369583.jpg') (Join-Path $dest 'product-gem-goshenite-diamond.jpg') -Force
Copy-Item (Join-Path $brain 'heliodor_yellow_gem_1791606389367.jpg') (Join-Path $dest 'product-gem-heliodor.jpg') -Force

Get-ChildItem -Path $dest -Filter 'product-gem-*.jpg' | Select-Object Name, Length
