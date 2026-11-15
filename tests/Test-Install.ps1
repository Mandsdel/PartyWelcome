$ErrorActionPreference = 'Stop'
$source = Split-Path -Parent $PSScriptRoot
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("PartyWelcome-test-" + [guid]::NewGuid())

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    & (Join-Path $source 'Install-PartyWelcome.ps1') -AddOnsPath $tempRoot
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw "Installer failed with exit code $LASTEXITCODE."
    }

    $installed = Join-Path $tempRoot 'PartyWelcome'
    $toc = Join-Path $installed 'PartyWelcome.toc'
    $files = Get-Content -LiteralPath $toc | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
    foreach ($file in $files) {
        $original = Join-Path $source $file
        $copy = Join-Path $installed $file
        if (-not (Test-Path -LiteralPath $copy -PathType Leaf)) {
            throw "Installer omitted $file."
        }
        if ((Get-FileHash -LiteralPath $original).Hash -ne (Get-FileHash -LiteralPath $copy).Hash) {
            throw "Installed $file differs from the source."
        }
    }
    Write-Host 'PartyWelcome installer checks passed.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
