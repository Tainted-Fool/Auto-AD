# Import the AD module
Import-Module ActiveDirectory

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
        New-AD-Groups($csvFile)
    }
    else 
    {
        Write-Host "Invalid CSV path, try again"
        Get-CSVFile
    }
}

# Declare a function to add group members
function Add-GroupMembers($group, $groupName)
{
    $members = Get-ADUser -Filter 'Department -like $group'

    foreach ($member in $members)
    {
        Add-ADGroupMember -Identity $groupName -Members $member.SamAccountName -WhatIf
    }
}

# Declare function to create AD groups
function New-AD-Groups($csvFile)
{
    # Path to the security group OU
    $groupOU = "OU=Groups,OU=Azkaban,DC=Azkaban,DC=local"
    
    # Get a list of the groups
    $groups = $csvFile.Houses | Select-Object -Unique

    # Loop through each group
    foreach ($group in $groups)
    {
        # Create a hash table for array splatting
        $groupGlobal =
        @{
            Name            = "$group Users"
            Path            = $groupOU
            GroupScope      = "Global"
            GroupCategory   = "Security"
            Description     = "Members of this group are in the $group house"
        }
        
        # Create a hash table for array splatting
        $groupDomainLocal =
        @{
            Name            = "$group Resources"
            Path            = $groupOU
            GroupScope      = "DomainLocal"
            GroupCategory   = "Security"
            Description     = "Members of this group have access to the $group house resources"
        }

        # Create the Global group
        New-ADGroup @groupGlobal -WhatIf
        
        # Create the DomainLocal group
        New-ADGroup @groupDomainLocal -WhatIf
        
        # Add members to the Global group
        Add-GroupMembers $group $groupGlobal.Name

        # Add Global group to the DomainLocal group
        Add-ADGroupMember -Identity $groupDomainLocal.Name -Members $groupGlobal.Name -WhatIf
    }

}

# Call functions
Get-CSVFile