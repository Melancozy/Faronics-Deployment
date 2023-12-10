# List of GUIDs to uninstall in sequence
$guidsToUninstall = @(
    "{5FA83AA9-59E0-4F8B-AD80-7CF520620364}_is1",
    "{95AF258D-FEA4-440C-9E25-53D2FEEB187B}_is1",
    "{86727A02-3679-442A-AECA-DC1C3430AC89}_is1",
    "{BD5DA351-0699-4399-96A9-EFC31DBE7767}_is1"
)

# Function to read registry value
function ReadRegistryValue {
    param (
        [string]$guid
    )
    $regKey = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$guid"
    $regData = Get-ItemProperty -Path $regKey -Name "QuietUninstallString" | Select-Object -ExpandProperty "QuietUninstallString"
    return $regData
}

# Function to uninstall a program
function UninstallProgram {
    param (
        [string]$guid
    )

    Write-Host "Uninstalling program with GUID: $guid"

    # Read uninstall path from registry
    $regData = ReadRegistryValue -guid $guid

    if ($regData) {
        # Remove quotes from the uninstall path
        $uninstallPath = $regData -replace '"', ''

        # Split the path into executable and arguments
        $executable, $arguments = $uninstallPath -split ' ', 2

        if (Test-Path -Path $executable) {
            Write-Host "Running quiet uninstaller: $executable $arguments"
            Start-Process -FilePath $executable -ArgumentList $arguments -Wait
        } else {
            Write-Host "Executable not found: $executable. Unable to uninstall."
        }
    } else {
        Write-Host "Uninstall path not found in the registry for program with GUID: $guid. Unable to uninstall."
    }
}

# Uninstall programs in sequence
foreach ($guid in $guidsToUninstall) {
    UninstallProgram -guid $guid
}
