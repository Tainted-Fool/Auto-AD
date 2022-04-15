# Declare function to get CSV file
function Get-CSVFile 
{
    # Ask user for CSV path
    $csvPath = Read-Host -Prompt "Enter CSV path`nExample 'C:\pathToFile.csv'"
    Clear-Host

    # Check if path exist and is a CSV file, if not run function again
    if ((Test-Path $csvPath) -and ($csvPath -like "*.csv")) 
    {
        # Import CSV file and call function to create AD users
        $csvFile = Import-Csv -Path $csvPath
        New-SMBFolders($csvFile)
    }
    else 
    {
        Write-Host "Invalid CSV path, try again"
        Get-CSVFile
    }
}

# Declare function to create SMB directories
function New-SMBFolders($csvFile)
{
    # Prompt user for folder path
    $folderPath = Read-Host -Prompt "Enter path to create folders`nExample 'D:\shared'"

    # Check if path exists
    if (Test-Path $folderPath)
    {
        # Create a list of directories
        $folders = $csvFile.Houses | Select-Object -Unique

        # Check if path ends with backslash
        if ($folderPath[-1] -ne "\")
        {
            $folderPath += "\"
        }

        # Create SMB directories
        foreach ($folder in $folders)
        {
            $newFolderPath = $folderPath + $folder
            New-Item -ItemType Directory -Path $newFolderPath -WhatIf
            New-SmbShare -Name $folder -Path $newFolderPath -FullAccess Everyone -WhatIf
        }
    }    
}

# Call the functions
Get-CSVFile