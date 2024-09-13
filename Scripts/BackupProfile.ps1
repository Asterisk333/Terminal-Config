function Backup-PowerShellProfile {
    param (
        [string]$BackupPath = "$env:USERPROFILE\Documents\PowerShellProfileBackup"
    )

    # Ensure the backup path exists
    if (-not (Test-Path -Path $BackupPath)) {
        New-Item -Path $BackupPath -ItemType Directory -Force
    }

    # Define profile paths for different hosts
    $profiles = @(
        $PROFILE,                      # Current PowerShell profile
        $PROFILE.AllUsersCurrentHost,  # All users profile for current host
        $PROFILE.AllUsersAllHosts      # All users profile for all hosts
    )

    foreach ($profile in $profiles) {
        if (Test-Path -Path $profile) {
            $fileName = [System.IO.Path]::GetFileName($profile)
            $backupFile = Join-Path -Path $BackupPath -ChildPath "$fileName.bak"
            
            Write-Output "Backing up profile: $profile"
            Copy-Item -Path $profile -Destination $backupFile -Force
        } else {
            Write-Warning "Profile not found: $profile"
        }
    }

    Write-Output "Backup completed. Profiles backed up to $BackupPath."
}

# Run the function
Backup-PowerShellProfile

