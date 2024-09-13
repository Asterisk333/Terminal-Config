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

    function Download-AndExtractRepo {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$RepoUrl
    )

    # Define paths
    $psVersion = $PSVersionTable.PSVersion.Major

    if($psVersion -le 7){
	$destinationFolder = "$env:USERPROFILE\Documents\WindowsPowerShell"
    	$copyPath = "$env:USERPROFILE\Documents\WindowsPowerShell\Terminal-Config\Terminal-Config-main\*"		
    }else{
    	$destinationFolder = "$env:USERPROFILE\Documents\PowerShell"
    	$copyPath = "$env:USERPROFILE\Documents\PowerShell\Terminal-Config\Terminal-Config-main\*"
    }

    	$zipPath = $destinationFolder + "\Terminal-Config.zip"
    	$extractPath = $destinationFolder + "\Terminal-Config"

    # Create the destination directory if it doesn't exist
    if (-not (Test-Path -Path $destinationFolder)) {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
    }

    # Download the ZIP archive of the repository
    Write-Host "Downloading repository from $RepoUrl..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $RepoUrl -OutFile $zipPath

    # Extract the ZIP archive
    Write-Host "Extracting contents to $extractPath..." -ForegroundColor Yellow
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    # Define the final path to move the contents
    $finalPath = $destinationFolder

    # Ensure the final path exists
    if (Test-Path -Path $finalPath) {
        # Move contents from the extracted folder to the destination folder
        Copy-Item -Path $copyPath -Destination $destinationFolder -Recurse -Force

        # Clean up the extracted folder and ZIP file
        Remove-Item -Path $extractPath -Recurse -Force
        Remove-Item -Path $zipPath -Force

        Write-Host "Repository contents moved to $destinationFolder and cleaned up." -ForegroundColor Green
    } else {
        Write-Host "Failed to extract repository contents." -ForegroundColor Red
    }
}

# Run the function
Backup-PowerShellProfile

$repoUrl = "https://github.com/Asterisk333/Terminal-Config/archive/refs/heads/main.zip"
Download-AndExtractRepo -RepoUrl $repoUrl

Install-Module -Name oh-my-posh -Scope CurrentUser -Force
