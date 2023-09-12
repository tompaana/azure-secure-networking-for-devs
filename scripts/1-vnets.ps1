#!/usr/bin/env pwsh

param(
    [string]$TeamName = $env:TEAM_NAME,
    [string]$PrimaryLocation = $env:PRIMARY_LOCATION,
    [string]$SecondaryLocation = $env:SECONDARY_LOCATION,
    [string]$HubLocation = $env:HUB_LOCATION
)

if ($TeamName.Length -lt 2) {
    Write-Error "Invalid argument: Team name missing or too short (must be at least 2 characters long)"
    exit 1
}

$Environment = "dev"

.\subscripts\1-1-vnet.ps1 $TeamName $HubLocation "rg-hub-${TeamName}-${Environment}" "10.0.0"
.\subscripts\1-1-vnet.ps1 $TeamName $PrimaryLocation "rg-${TeamName}-${Environment}-eu" "10.0.4"
.\subscripts\1-1-vnet.ps1 $TeamName $SecondaryLocation "rg-${TeamName}-${Environment}-us" "10.0.8"
