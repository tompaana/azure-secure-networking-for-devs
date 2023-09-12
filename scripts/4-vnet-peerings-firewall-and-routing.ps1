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

$ResourceGroupNameHub = "rg-hub-${TeamName}-${Environment}"
$ResourceGroupNameEu = "rg-${TeamName}-${Environment}-eu"
$ResourceGroupNameUs = "rg-${TeamName}-${Environment}-us"

$VnetNameEu = "vnet-${TeamName}-${Environment}-${PrimaryLocation}"
$VnetNameUs = "vnet-${TeamName}-${Environment}-${SecondaryLocation}"
$VnetNameHub = "vnet-${TeamName}-${Environment}-${HubLocation}"

Write-Output "`nPeering virtual networks to using the hub and spoke model..."

.\subscripts\4-1-vnet-peerings.ps1 -ResourceGroupName1 $ResourceGroupNameHub -VnetName1 $VnetNameHub -ResourceGroupName2 $ResourceGroupNameEu -VnetName2 $VnetNameEu
.\subscripts\4-1-vnet-peerings.ps1 -ResourceGroupName1 $ResourceGroupNameHub -VnetName1 $VnetNameHub -ResourceGroupName2 $ResourceGroupNameUs -VnetName2 $VnetNameUs

.\subscripts\2-1-subnet.ps1 $TeamName $HubLocation $ResourceGroupNameHub "firewall" "10.0.0.128/26"

.\subscripts\4-2-firewall.ps1 -TeamName $TeamName -Location $HubLocation

# TODO: Routing
