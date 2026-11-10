[CmdletBinding()]
param(
    [string]$AddOnsPath = 'D:\World of Warcraft\_forever_\Interface\AddOns'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    if (-not (Test-Path -LiteralPath $AddOnsPath -PathType Container)) {
        throw "WoW AddOns directory was not found: $AddOnsPath"
    }

    $destination = Join-Path $AddOnsPath 'PartyWelcome'
    if (-not (Test-Path -LiteralPath $destination -PathType Container)) {
        New-Item -ItemType Directory -Path $destination | Out-Null
    }

    foreach ($file in 'PartyWelcome.toc', 'Core.lua') {
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination (Join-Path $destination $file) -Force
    }

    Write-Host "Installed PartyWelcome to $destination"
    Write-Host 'Enable PartyWelcome at character select.'
}
catch {
    Write-Error "PartyWelcome installation failed. $($_.Exception.Message)"
    exit 1
}
