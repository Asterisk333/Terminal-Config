# 1.0.8030.24604

## $Env:PATH management
Function Add-DirectoryToPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName")]
        [string] $path,
        [string] $variable = "PATH",

        [switch] $clear,
        [switch] $force,
        [switch] $prepend,
        [switch] $whatIf
    )

    BEGIN {

        ## normalize paths

        $count = 0

        $paths = @()

        if (-not $clear.IsPresent) {

            $environ = Invoke-Expression "`$Env:$variable"
            $environ.Split(";") | ForEach-Object {
                if ($_.Length -gt 0) {
                    $count = $count + 1
                    $paths += $_.ToLowerInvariant()
                }
            }

            Write-Verbose "Currently $($count) entries in `$env:$variable"
        }

        Function Array-Contains {
            param(
                [string[]] $array,
                [string] $item
            )

            $any = $array | Where-Object -FilterScript {
                $_ -eq $item
            }

            Write-Output ($null -ne $any)
        }
    }

    PROCESS {

        ## Using [IO.Directory]::Exists() instead of Test-Path for performance purposes

        ##$path = $path -replace "^(.*);+$", "`$1"
        ##$path = $path -replace "^(.*)\\$", "`$1"
        if ([IO.Directory]::Exists($path) -or $force.IsPresent) {

            #$path = (Resolve-Path -Path $path).Path
            $path = $path.Trim()

            $newPath = $path.ToLowerInvariant()
            if (-not (Array-Contains -Array $paths -Item $newPath)) {
                if ($whatIf.IsPresent) {
                    Write-Host $path
                }

                if ($prepend.IsPresent) { $paths = , $path + $paths }
                else { $paths += $path }

                Write-Verbose "Adding $($path) to `$env:$variable"
            }
        }
        else {

            Write-Host "Invalid entry in `$Env:$($variable): ``$path``" -ForegroundColor Yellow

        }
    }

    END {

        ## re-create PATH environment variable

        $separator = [IO.Path]::PathSeparator
        $joinedPaths = [string]::Join($separator, $paths)

        if ($whatIf.IsPresent) {
            Write-Output $joinedPaths
        }
        else {
            Invoke-Expression " `$env:$variable = `"$joinedPaths`" "
        }
    }

}

## Well-known profiles script
Function Get-DefaultProfile {
    $___profile = Join-Path -Path (Split-Path -Path $profile -Parent) -ChildPath "profile.ps1"
    Write-Output $___profile
}
Function Remove-DefaultProfile {
    $___profile = Get-DefaultProfile
    if (Test-Path $___profile) { 
        Write-Host "Removing default profile file." -ForegroundColor Yellow
        Remove-Item $___profile -Force
    }
}

## 

if (-not (Get-Module -Name Pwsh-Profile -ListAvailable)) {
    Write-Host "Missing required 'Pwsh-Profile' module." -ForegroundColor Yellow
    Write-Host "Please, install this module once using the following command:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Pwsh-Profile -Repository PSGallery -Scope CurrentUser -Force" -ForegroundColor DarkGray

    return
} else {

    $update8030 = Join-Path -Path (Get-CachedPowerShellProfileFolder) -ChildPath "pwsh_profile_8030"
    if (-not (Test-Path $update8030)){
        $online = Find-Module -Name Pwsh-Profile -Repository PSGallery
        $current = Get-module -Name Pwsh-Profile -ListAvailable
        if ($online.Version -gt $current.Version) {
            Write-Host "Required 'Pwsh-Profile' module has updates." -ForegroundColor Yellow
            Write-Host "Please, update this module using the following command:" -ForegroundColor Yellow
            Write-Host "  Update-Module -Name Pwsh-Profile -Force" -ForegroundColor DarkGray
        }
        Set-Content -Path $update8030 -Value $null
    }
}

CheckFor-ProfileUpdate | Out-Null
Load-Profile "profiles" -Quiet

#####Installing Vim,Nano&Git#####




if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not installed. Installing winget..."
    $AppInstallerUrl = "https://aka.ms/Microsoft.DesktopAppInstaller"
    $AppxBundlePath = "$env:TEMP\AppInstaller.appxbundle"
        
    # Download the App Installer
    Write-Output "Downloading App Installer from $AppInstallerUrl..."
    Invoke-WebRequest -Uri $AppInstallerUrl -OutFile $AppxBundlePath
        
    # Install the App Installer
    Write-Output "Installing App Installer..."
    Add-AppxPackage -Path $AppxBundlePath

    # Verify installation
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Output "winget has been installed successfully."
    } else {
        Write-Output "Failed to install winget."
    }
} else {
        Write-Output "winget is already installed."
}


# Install Vim if not installed
if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    Write-Output "Vim is not installed. Installing Vim..."
    winget install --id=Vim.Vim -e
} else {
    Write-Output "Vim is already installed."
}

# Install Nano if not installed
if (-not (Get-Command nano -ErrorAction SilentlyContinue)) {
    Write-Output "Nano is not installed. Installing Nano..."
    winget install --id=GNU.nano -e
} else {
    Write-Output "Nano is already installed."
}

# Install Git if not installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "Git is not installed. Installing Git..."
    winget install --id=Git.Git -e
} else {
    Write-Output "Git is already installed."
}


#####Installing Fonts#####
~\Documents\PowerShell\Scripts\InstallFont.ps1


#####################################

function touch($file) { "" | Out-File $file -Encoding ASCII }

function ff($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Output "$($_.FullName)"
    }
}

# Network Utilities
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# Function to test if ports are open
function Test-Ports {
    param (
        [string]$ports,
        [string]$device
    )

    # Split the ports string into an array
    $portArray = $ports -split ','

    # Test each port
    foreach ($port in $portArray) {
        $result = Test-NetConnection -ComputerName $device -Port $port
        if ($result.TcpTestSucceeded) {
            Write-Output "Port $port is open on $device."
        } else {
            Write-Output "Port $port is closed on $device."
        }
    }
}

# Open WinUtil
function winutil {
	iwr -useb https://christitus.com/win | iex
}

function uptime {
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Get-WmiObject win32_operatingsystem | Select-Object @{Name='LastBootUpTime'; Expression={$_.ConverttoDateTime($_.lastbootuptime)}} | Format-Table -HideTableHeaders
    } else {
        net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
    }
}

function reload-profile {
    & $profile
}

function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function hb {
    if ($args.Length -eq 0) {
        Write-Error "No file path specified."
        return
    }
    
    $FilePath = $args[0]
    
    if (Test-Path $FilePath) {
        $Content = Get-Content $FilePath -Raw
    } else {
        Write-Error "File path does not exist."
        return
    }
    
    $uri = "http://bin.christitus.com/documents"
    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
        $hasteKey = $response.key
        $url = "http://bin.christitus.com/$hasteKey"
        Write-Output $url
    } catch {
        Write-Error "Failed to upload the document. Error: $_"
    }
}

function grep($regex, $dir) {
    if ( $dir ) {
        Get-ChildItem $dir | select-string $regex
        return
    }
    $input | select-string $regex
}

function df {
    get-volume
}

function sed($file, $find, $replace) {
    (Get-Content $file).replace("$find", $replace) | Set-Content $file
}


function pkill($name) {
    Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
    Get-Process $name
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10, [switch]$f = $false)
  Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

#Copy File or Directory
function copy {
	 param (
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Destination -Recurse
        Write-Output "Copied $Source to $Destination"
    } else {
        Write-Output "Source path does not exist."
    }
}
#move file or directory
function move {
	 param (
        [string]$Source,
        [string]$Destination
    )
	try {
        # Check if the source exists
        if (-Not (Test-Path -Path $Source)) {
            Write-Host "Source path '$Source' does not exist."
            return
        }

        # Ensure the destination directory exists, create if it doesn't
        if (-Not (Test-Path -Path $Destination)) {
            New-Item -ItemType Directory -Path $Destination | Out-Null
        }

        # Move the file or directory
        Move-Item -Path $Source -Destination $Destination
        Write-Host "Moved '$Source' to '$Destination' successfully."
    } catch {
        Write-Host "Error moving '$Source' to '$Destination': $_"
    }	
}
#rename file or directory
function rename {
	param (
        [string]$Path,
        [string]$NewName
    )

    try {
        # Check if the path exists
        if (-Not (Test-Path -Path $Path)) {
            Write-Host "Path '$Path' does not exist."
            return
        }

        # Get the parent directory of the path
        $ParentDirectory = Split-Path -Path $Path -Parent

        # Construct the new path
        $NewPath = Join-Path -Path $ParentDirectory -ChildPath $NewName

        # Rename the file or directory
        Rename-Item -Path $Path -NewName $NewName
        Write-Host "Renamed '$Path' to '$NewPath' successfully."
    } catch {
        Write-Host "Error renaming '$Path' to '$NewName': $_"
    }
}

### Quality of Life Aliases

# Navigation Shortcuts
function docs { Set-Location -Path $HOME\Documents }

function dtop { Set-Location -Path $HOME\Desktop }

# Quick Access to Editing the Profile
function ep { vim $PROFILE }

# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
	Clear-DnsClientCache
	Write-Host "DNS has been flushed"
}

#####Git Stuff#####
#lazy git commit
function gcom {
	git add -A
	git commit -m "$args"
}
#lazy git push
function gpush {
	git push -u origin main
}
#lazy remote add
function gremote {
	git remote add origin "$args"
}

#####Personalstuff#####
function toolbox {
	C:\tools\toolbox\toolbox-acesser.ps1
}

function kys {
	exit	
}

# Enhanced PowerShell Experience
Set-PSReadLineOption -Colors @{
    Command = 'Yellow'
    Parameter = 'Green'
    String = 'DarkCyan'
}

Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Enter' -Function ValidateAndAcceptLine

$scriptblock = {
    param($wordToComplete, $commandAst, $cursorPosition)
    dotnet complete --position $cursorPosition $commandAst.ToString() |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock


# Help Function
function Show-Help {
    @"
PowerShell Profile Help
=======================

File Operations:
----------------
touch <file>       - Creates a new empty file.
ff <name>          - Finds files recursively with the specified name.
unzip <file>       - Extracts a zip file to the current directory.
sed <file> <find> <replace> 	- Replaces text in a file.
head <path> [n]    - Displays the first n lines of a file (default 10).
tail <path> [n]    - Displays the last n lines of a file (default 10).
nf <name>          - Creates a new file with the specified name.
mkcd <dir>         - Creates and changes to a new directory.
copy <src> <dest>  - Copies file or folder to destination
move <src> <dest>  - Moves file or folder to destination
rename <path> <name>  - Renames file to name


Network Utilities:
------------------
Get-PubIP          - Retrieves the public IP address of the machine.
winutil            - Runs the WinUtil script from Chris Titus Tech.
flushdns           - Clears the DNS cache.
Test-Ports <ports> <Device>	- Tests wich ports are open in the device. eg. "123,456,678" 

System Information:
-------------------
uptime             - Displays the system uptime.
sysinfo            - Displays detailed system information.

Process Management:
-------------------
pkill <name>       - Kills processes by name.
pgrep <name>       - Lists processes by name.
k9 <name>          - Kills a process by name.

Directory Navigation:
---------------------
docs               - Changes the current directory to the user's Documents folder.
dtop               - Changes the current directory to the user's Desktop folder.

Profile Management:
-------------------
reload-profile     - Reloads the current user's PowerShell profile.
ep                 - Opens the profile for editing.

Miscellaneous:
--------------
hb <file>          - Uploads the specified file's content to a hastebin-like service and returns the URL.
grep <regex> [dir] - Searches for a regex pattern in files within the specified directory or from the pipeline input.
df                 - Displays information about volumes.
la                 - Lists all files in the current directory with detailed formatting.
ll                 - Lists all files, including hidden, in the current directory with detailed formatting.

Git:
----
gcom <msg>	   - Adds all changes in directory and cpmmits them with message
gpush		   - Pushes to git
gremote <url>	   - Adds a remote repo		


Use 'Show-Help' to display this help message.
"@
}


Write-Host "Use 'Show-Help' to display help"


