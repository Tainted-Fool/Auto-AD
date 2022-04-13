# *NOTE: make sure to install the proper RSAT tool
# RSAT: Remote Access Management Tools
# RSAT: Active Directory Domain Services and Lightweight Directory Services Tools

# *NOTE: make sure to also enable remote powershell
# Enable this on the server we are trying to remote to
# Enable-PSRemoting -Force

# Connect to the remote server
# Enter-PSSession -ComputerName <hostName> -Credential <domainName\userName>

# We can connect by IP if you add it to trusted host on local computer
# Set-Item WSMan:\localhost\Client\TrustedHosts -Value <remoteIP>
# Enter-PSSession -ComputerName <remoteIP> -Credential <domainName\userName>

# We can run remote scripts using this command
# Invoke-Command -FilePath <pathToFile> -ComputerName <hostName> -Credential <domainName\userName>

# Import the Active Directory module
Import-Module ActiveDirectory

# Create a temporary password for the users
$tempPass = Read-Host -AsSecureString -Prompt "Enter a temporary password"

# Declare function to get CSV file
function Get-CSVFile 
{
    # Ask user for CSV path
    $csvPath = Read-Host -Prompt "Enter CSV path`nExample 'C:\pathToFile.csv'"
    Clear-Host

    # Check if path exist and is a CSV file, if not run function again
    if ((Test-Path $csvPath) -and ($csvPath -like "*.csv")) 
    {
        # Import CSV file
        $csvFile = Import-Csv -Path $csvPath
        New-AD-Users($csvFile)
    }
    else 
    {
        Write-Host "Invalid CSV path, try again"
        Get-CSVFile
    }
}

# Declare function to create AD-Users
function New-AD-Users($csvFile)
{    
    # Loop through the CSV file
    foreach ($user in $csvFile)
    {
        # Loop through each row and assign a variable
        # This is known as 'array splatting'
        $userInfo = 
        @{
            # option/flag name     # column name from CSV file 
            Name                    = $user.FullName
            DisplayName             = $user.FullName
            GivenName               = $user.FirstName
            SurName                 = $user.LastName
            SamAccountName          = $user.SamAccountName
            Department              = $user.Houses
            EmailAddress            = $user.Email
            Path                    = $user.Path
            AccountPassword         = $tempPass
            ChangePasswordAtLogon   = $true
            Enabled                 = $true
        }
        # Create new AD user
        New-ADUser @userInfo -WhatIf 
    }
}

# Call the function
Get-CSVFile
