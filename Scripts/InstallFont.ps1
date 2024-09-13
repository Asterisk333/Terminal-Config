# Define the font name and download URL
$fontName = "0xProto Nerd Font"
$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/0xProto.zip"

# Function to check if the font file is already installed
function Test-FontInstalled {
    param (
        [string]$fontFileName
    )

    $fontsPath = "$env:SystemRoot\Fonts"

    # Check if the specific font file exists in the Fonts directory
    if (Test-Path "$fontsPath\$fontFileName") {
        return $true
    }
    return $false
}

# Function to download and install the font
function Install-Font {
    param (
        [string]$fontUrl
    )

    $tempPath = [System.IO.Path]::GetTempPath()
    $zipPath = "$tempPath\0xProto.zip"
    $fontPath = "$tempPath\0xProto"

    # Download the font zip file
    Invoke-WebRequest -Uri $fontUrl -OutFile $zipPath

    # Extract the zip file
    Expand-Archive -Path $zipPath -DestinationPath $fontPath

    # Copy the font files to the Fonts directory
    $fontFiles = Get-ChildItem -Path "$fontPath" -Filter *.ttf

    foreach ($fontFile in $fontFiles) {
        $fontFileName = $fontFile.Name

        # Check if the font is already installed
        if (Test-FontInstalled -fontFileName $fontFileName) {
            Write-Output "$fontFileName is already installed. Skipping."
        } else {
            Write-Output "Installing $fontFileName..."
            Copy-Item -Path $fontFile.FullName -Destination "$env:SystemRoot\Fonts" -Force

            # Add the font to the Windows Fonts registry
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                -Name "$fontFileName (TrueType)" `
                -Value $fontFileName

            Write-Output "$fontFileName installed successfully."
        }
    }

    # Clean up
    Remove-Item -Path $zipPath -Force
    Remove-Item -Path $fontPath -Recurse -Force
}

# Check and install the font if not already installed
if (Test-FontInstalled -fontFileName "0xProtoNerdFont-Regular.ttf") {
    Write-Output "$fontName is already installed."
} else {
    Write-Output "$fontName is not installed. Installing..."
    Install-Font -fontUrl $fontUrl
}

