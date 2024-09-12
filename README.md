# Terminal-Config

This is a repo for me to store my personal commands and Terminal config so I can use it from everywhere

This is still WIP and will be updated soon

## Custom comands:

### File Operations:
---
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


### Network Utilities:
---
Get-PubIP          - Retrieves the public IP address of the machine.
winutil            - Runs the WinUtil script from Chris Titus Tech.
flushdns           - Clears the DNS cache.

### System Information:
---
uptime             - Displays the system uptime.
sysinfo            - Displays detailed system information.

### Process Management:
---
pkill <name>       - Kills processes by name.
pgrep <name>       - Lists processes by name.
k9 <name>          - Kills a process by name.

### Directory Navigation:
---
docs               - Changes the current directory to the user's Documents folder.
dtop               - Changes the current directory to the user's Desktop folder.

### Profile Management:
---
reload-profile     - Reloads the current user's PowerShell profile.
ep                 - Opens the profile for editing.

### Miscellaneous:
---
hb <file>          - Uploads the specified file's content to a hastebin-like service and returns the URL.
grep <regex> [dir] - Searches for a regex pattern in files within the specified directory or from the pipeline input.
df                 - Displays information about volumes.
la                 - Lists all files in the current directory with detailed formatting.
ll                 - Lists all files, including hidden, in the current directory with detailed formatting.
gcom <msg>	   - Adds all changes in directory and cpmmits them with message
gpush		   - Pushes to git


Use 'Show-Help' to display this help message.
