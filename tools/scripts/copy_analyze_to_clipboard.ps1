cd C:\Users\Danie\garden_planner
New-Item -ItemType Directory -Force docs\reports | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$file = "docs\reports\flutter_analyze_$stamp.txt"
flutter analyze 2>&1 | Tee-Object -FilePath $file
Get-Content $file -Raw | Set-Clipboard
Write-Host "Analyzer output copied to clipboard."
Write-Host "Saved: $file"
