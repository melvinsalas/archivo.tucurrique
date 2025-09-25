Param(
    [string]$BaseDir = "."
)

$ErrorActionPreference = "Stop"

$FilesDir = Join-Path $BaseDir "_files"
$MinutesDir = Join-Path $BaseDir "_minutes"

if (-not (Test-Path -Path $FilesDir -PathType Container)) {
    Write-Error "Error: no existe la carpeta $FilesDir"
    exit 1
}

New-Item -ItemType Directory -Force -Path $MinutesDir | Out-Null

function Normalize-Spaces {
    param([string]$s)
    if ($null -eq $s) { return "" }
    $s = $s -replace "_"," "
    $s = $s -replace "\s+"," "
    $s = $s.Trim()
    return $s
}

function To-TitleCase {
    param([string]$s)
    if ([string]::IsNullOrWhiteSpace($s)) { return "" }
    $culture = [System.Globalization.CultureInfo]::GetCultureInfo("es-ES")
    $tc = $culture.TextInfo
    return $tc.ToTitleCase($s.ToLower($culture))
}

function Remove-Diacritics {
    param([string]$s)
    if ($null -eq $s) { return "" }
    $normalized = $s.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $normalized.ToCharArray()) {
        $uc = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch)
        if ($uc -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($ch)
        }
    }
    return $sb.ToString().Normalize([Text.NormalizationForm]::FormC)
}

function Slugify {
    param([string]$s)
    if ($null -eq $s) { return "" }
    $s = Remove-Diacritics $s
    $s = $s.ToLowerInvariant()
    $s = [Regex]::Replace($s, "[^a-z0-9]+", "-")
    $s = $s.Trim("-")
    return $s
}

$pdfs = Get-ChildItem -Path $FilesDir -Recurse -File -Include *.pdf, *.PDF
foreach ($pdf in $pdfs) {
    # Ruta relativa correcta respecto a _files (sin prefijos absolutos)
    $relFromFiles = [IO.Path]::GetRelativePath($FilesDir, $pdf.FullName)
    $relPath = ($relFromFiles -replace "\\", "/")
    $basenameWithExt = [IO.Path]::GetFileName($relPath)
    $basenameNoExt = [IO.Path]::GetFileNameWithoutExtension($basenameWithExt)

    # En _minutes, espejar árbol bajo _files y reemplazar extensión por .md (case-insensitive)
    if ($relPath -match "(?i)\.pdf$") {
        $relMinutesPath = $relPath.Substring(0, $relPath.Length - 4) + ".md"
    } else {
        $relMinutesPath = $relPath + ".md"
    }
    $targetMd = Join-Path $MinutesDir $relMinutesPath
    $targetDir = Split-Path $targetMd -Parent
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    if (Test-Path $targetMd) {
        Write-Host "Saltado (ya existe): $targetMd"
        continue
    }

    $cleanName = Normalize-Spaces $basenameNoExt
    $title = To-TitleCase $cleanName

    $parts = @()
    if (-not [string]::IsNullOrWhiteSpace($cleanName)) {
        $parts = $cleanName -split "\s+"
    }
    if ($parts.Count -ge 2) {
        $typeField = $parts[1].ToLowerInvariant()
    } else {
        $typeField = "general"
    }

    $firstDir = ($relPath -split "/")[0]
    if ($firstDir -match '^[0-9]{4}$') {
        $dateField = "$firstDir-01-01"
    } else {
        $dateField = "2025"
    }

    $fileField = "/files/$relPath"
    $permalinkSlug = Slugify $cleanName
    $permalink = "actas/$permalinkSlug"

    $frontMatter = @(
        "---"
        "title: $title"
        "type: $typeField"
        "date: $dateField"
        "file: $fileField"
        "permalink: $permalink"
        "---"
    ) -join "`r`n"

    $frontMatter | Out-File -FilePath $targetMd -Encoding UTF8 -Force
    Write-Host "Creado: $targetMd"
}

Write-Host "Hecho. Front matter generado en _minutes."
