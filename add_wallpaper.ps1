param (
    [string]$SourceFile,
    [string]$TargetFolder,
    [string]$TargetFileName,
    [string]$Id,
    [string]$Name,
    [string]$Category,
    [string]$Team = "",
    [string]$Color,
    [string]$Tags
)

$repoPath = "C:\Users\welli\OneDrive\Documentos\Antigravity\Projetos\copa-assets"
$jsonPath = Join-Path $repoPath "wallpapers.json"
$targetDir = Join-Path $repoPath "images\wallpapers\$TargetFolder"

if ($Team -eq "none") {
    $Team = ""
}

# Garante que o diretório existe
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

$targetFileFullPath = Join-Path $targetDir $TargetFileName
Move-Item -Path $SourceFile -Destination $targetFileFullPath -Force

# Lendo o JSON
$json = Get-Content $jsonPath | ConvertFrom-Json

# Criando a nova entrada
$tagsArray = $Tags -split "," | ForEach-Object { $_.Trim() }

# GitHub raw URL (forçar forward slashes)
$urlFolder = $TargetFolder -replace '\\', '/'
$assetPath = "https://raw.githubusercontent.com/Wellitiz/copa-assets/main/images/wallpapers/$urlFolder/$TargetFileName"

$newEntry = @{
    id = $Id
    name = $Name
    assetPath = $assetPath
    category = $Category
    team = $Team
    predominantColor = $Color
    isPremium = $false
    isNew = $true
    tags = $tagsArray
}

# Se o JSON original estiver vazio, inicializa a lista
if ($null -eq $json) {
    $json = @()
}

$json += $newEntry

# Salva de volta formatado
$json | ConvertTo-Json -Depth 10 | Set-Content $jsonPath

Write-Host "Adicionado: $Name em $TargetFolder/$TargetFileName"
