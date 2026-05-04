# Paths
$rootPath = "C:\Users\lukep\lukes_repo"
$repoPath = "$rootPath\docs"
$zipsPath = "$repoPath\zips"
$sourcePath = "$rootPath\repository.lukes_repo"

# Ensure folders exist
New-Item -ItemType Directory -Force -Path $zipsPath | Out-Null

# --- 1. Build ZIP ---
$version = "1.0.0"
$addonId = "repository.lukes_repo"
$zipOutputPath = "$zipsPath\$addonId"

New-Item -ItemType Directory -Force -Path $zipOutputPath | Out-Null

$zipFile = "$zipOutputPath\$addonId-$version.zip"

if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

# IMPORTANT: keep folder structure inside zip
Compress-Archive -Path $sourcePath -DestinationPath $zipFile

Write-Host "ZIP built: $zipFile"

# --- 2. Build addons.xml ---
$xml = "<?xml version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`"?>`n<addons>`n"

$addonXmlPath = "$sourcePath\addon.xml"

if (Test-Path $addonXmlPath) {
    $content = Get-Content $addonXmlPath -Raw

    if (![string]::IsNullOrWhiteSpace($content)) {
        $xml += $content.Trim()
    } else {
        Write-Warning "addon.xml is empty!"
    }
} else {
    Write-Warning "addon.xml not found!"
}

$xml += "`n</addons>"

$addonsXmlPath = "$repoPath\addons.xml"
$xml | Out-File $addonsXmlPath -Encoding UTF8

Write-Host "addons.xml created"

# --- 3. Generate MD5 ---
$md5 = Get-FileHash $addonsXmlPath -Algorithm MD5
$md5.Hash.ToLower() | Out-File "$repoPath\addons.xml.md5" -Encoding ASCII

Write-Host "MD5 generated"

Write-Host "✅ Repo build complete."
