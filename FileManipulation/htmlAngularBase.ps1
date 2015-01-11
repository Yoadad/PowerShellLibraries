clear

$mainFolderName = 'base_'

$configPath = "$PSSCRIPTROOT\htmlAngularBAse.json"
$config = (Get-Content $configPath) -join "`n" | ConvertFrom-Json

$baseFolder = "$PSSCRIPTROOT\base"
$mainFolder = $config.path + '\' + $mainFolderName

New-Item -ItemType Directory -Force -Path $mainFolder

Copy-Item -Path "$baseFolder\*" -Destination $mainFolder –Recurse

New-Item "$mainFolder\js\$mainFolderName.js" -type file -Force
New-Item "$mainFolder\css\$mainFolderName.css" -type file -Force

(gc "$mainFolder\index.html").replace('{*}',$mainFolderName)|sc "$mainFolder\index.html"
