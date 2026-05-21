[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# DSC passes the requested resource instance over stdin because the manifest sets input = stdin.
# For this smoke test, we only need to prove that the command was invoked and returned valid JSON.
$rawInput = [Console]::In.ReadToEnd()

$id = 'default'

if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    try {
        $inputObject = $rawInput | ConvertFrom-Json -ErrorAction Stop

        if ($null -ne $inputObject.id -and -not [string]::IsNullOrWhiteSpace([string]$inputObject.id)) {
            $id = [string]$inputObject.id
        }
    }
    catch {
        # Keep this intentionally forgiving for the smoke test.
        $id = 'input-parse-failed'
    }
}

$result = [ordered]@{
    _exist      = $true
    id          = $id
    message     = 'Hello from a minimal DSC v3 command resource running on Linux'
    platform    = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
    pwshVersion = $PSVersionTable.PSVersion.ToString()
}

$result | ConvertTo-Json -Depth 5 -Compress