# Define the folder path (equivalent to $HOME/.cache/td in Bash)
$folder = "$env:USERPROFILE\.cache\td"

# Create folder and default file if they don\u2019t exist
if (-not (Test-Path $folder)) {
    New-Item -Path $folder -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path "$folder\default.txt")) {
    New-Item -Path "$folder\default.txt" -ItemType File | Out-Null
}

# Function to view lists and tasks
function View-List {
    $files = Get-ChildItem -Path "$folder\*.txt" | ForEach-Object { $_.BaseName }
    if ($files.Count -gt 0) {
        $choose = $files | Out-GridView -Title "Select a list to view" -OutputMode Single
        if ($choose) {
            $options = Get-Content -Path "$folder\$choose.txt"
            if ($options.Count -gt 0) {
                $choice = $options | Out-GridView -Title "Select a task to view" -OutputMode Single
                if ($choice) {
                    Write-Output $choice
                }
            } else {
                Write-Output "List is empty"
            }
        }
    } else {
        Write-Output "No list found"
        exit 0
    }
}

# Function to add a task
function Add-Task {
    param ($file)
    $name = Read-Host "Enter task name"
    if (Test-Path $file) {
        Add-Content -Path $file -Value $name
    } else {
        New-Item -Path $file -ItemType File | Out-Null
        Add-Content -Path $file -Value $name
    }
}

# Function to remove a task
function Remove-Task {
    param ($file)
    if (-not (Test-Path $file)) {
        Write-Output "List not found"
        exit 1
    } else {
        $options = Get-Content -Path $file
        $choice = $options | Out-GridView -Title "Select a task to remove" -OutputMode Single
        if ($choice) {
            $options | Where-Object { $_ -ne $choice } | Set-Content -Path $file
        }
    }
}

# Function to remove a list
function Remove-List {
    param ($file)
    if (-not (Test-Path $file)) {
        Write-Output "List not found"
        exit 1
    } else {
        $confirm = Read-Host "Remove the $file? (Yep/Nope)"
        if ($confirm -eq "Yep") {
            Remove-Item -Path $file -Force
        } else {
            Write-Output "Didn't remove $file"
        }
    }
}

# Main logic based on arguments
if ($args.Count -eq 0) {
    View-List
} else {
    switch ($args[0]) {
        "a" {
            if ($args.Count -lt 2) {
                $file = "$folder\default.txt"
            } else {
                $file = "$folder\$($args[1]).txt"
            }
            Add-Task -file $file
        }
        "r" {
            if ($args.Count -lt 2) {
                $file = "$folder\default.txt"
            } else {
                $file = "$folder\$($args[1]).txt"
            }
            Remove-Task -file $file
        }
        "R" {
            if ($args.Count -lt 2) {
                $file = "$folder\default.txt"
            } else {
                $file = "$folder\$($args[1]).txt"
            }
            Remove-List -file $file
        }
        "h" {
            Write-Output "=============================="
            Write-Output "          | |_ __| |          "
            Write-Output "          | __/ _\` |         "
            Write-Output "          | || (_| |          "
            Write-Output "           \__\__,_|          "
            Write-Output "=============================="
            Write-Output ""
            Write-Output "Usage: td.ps1 <arg> [options]"
            Write-Output ""
            Write-Output "args:"
            Write-Output "\u251c\u2500\u2500a: Add a new task"
            Write-Output "\u2502  \u2514\u2500option1: name of the list, leave blank for default"
            Write-Output "\u251c\u2500\u2500r: Remove a task"
            Write-Output "\u2502  \u2514\u2500option1: name of the list, leave blank for default"
            Write-Output "\u251c\u2500\u2500R: Remove a list"
            Write-Output "\u2502  \u2514\u2500option1: name of the list, leave blank for default"
            Write-Output "\u2514\u2500\u2500h: Show help"
        }
        default {
            Write-Output "Unknown arg, please run 'td.ps1 h' for help"
        }
    }
}
