clear

$mainFolderName = 'test1'

$configPath = "$PSSCRIPTROOT\htmlAngularBAse.json"
$config = (Get-Content $configPath) -join "`n" | ConvertFrom-Json

$baseFolder = "$PSSCRIPTROOT\base"
$mainFolder = $config.path + '\' + $mainFolderName


Remove-Item $mainFolder -Force -Recurse
New-Item -ItemType Directory -Force -Path $mainFolder

Copy-Item -Path "$baseFolder\*" -Destination $mainFolder –Recurse


(gc "$mainFolder\index.html").replace('{*}',$mainFolderName)|sc "$mainFolder\index.html"
(gc "$mainFolder\js\base.js").replace('{*}',$mainFolderName)|sc "$mainFolder\js\base.js"

Rename-Item "$mainFolder\js\base.js" "$mainFolderName.js"
Rename-Item "$mainFolder\css\base.css" "$mainFolderName.css"

