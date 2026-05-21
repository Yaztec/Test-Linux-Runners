[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

$resultPath = Join-Path $repoRoot 'dsc-smoke-output.txt'

# Make the resource manifest discoverable. DSC requires command-resource manifests
# to be discoverable through PATH.
$resourcePath = Join-Path $repoRoot 'resources/SimpleGet'
$env:PATH = "$resourcePath$([IO.Path]::PathSeparator)$env:PATH"

# Optional, but useful for diagnosing path behaviour.
$env:DSC_RESOURCE_PATH = $resourcePath

@"
Repo root:          $repoRoot
Resource path:      $resourcePath
DSC_RESOURCE_PATH:  $env:DSC_RESOURCE_PATH
PATH starts with:   $($env:PATH.Split([IO.Path]::PathSeparator)[0])
"@ | Set-Content -Path $resultPath -Encoding utf8

"`n=== pwsh version ===" | Add-Content -Path $resultPath
$PSVersionTable | Out-String | Add-Content -Path $resultPath

"`n=== dsc version ===" | Add-Content -Path $resultPath
dsc --version 2>&1 | Out-String | Add-Content -Path $resultPath

"`n=== dsc resource list ===" | Add-Content -Path $resultPath
dsc resource list 2>&1 | Out-String | Add-Content -Path $resultPath

"`n=== dsc resource schema ===" | Add-Content -Path $resultPath
dsc resource schema --resource 'Contoso.Simple/SimpleGet' 2>&1 | Out-String | Add-Content -Path $resultPath

"`n=== dsc resource get ===" | Add-Content -Path $resultPath

# Use stdin JSON so we do not have to depend on argument-quoting behaviour.
'{"id":"linux-smoke"}' | dsc resource get --resource 'Contoso.Simple/SimpleGet' 2>&1 |
    Tee-Object -FilePath $resultPath -Append

"`n=== done ===" | Add-Content -Path $resultPath

Write-Host "Smoke output written to $resultPath"
Get-Content -Path $resultPath