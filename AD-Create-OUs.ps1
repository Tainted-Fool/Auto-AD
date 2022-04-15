# Import the Active Directory module
# *NOTE* make sure to install the proper RSAT tool
Import-Module ActiveDirectory

# Create root OU
New-ADOrganizationalUnit 'Azkaban'

# Create child OUs
$OUs = 
@(
    'Users'
    'Groups'
    'Computers'
    'Servers'
)

$ouPath = "DC=Azkaban,DC=local"
foreach ($ou in $OUs)
{
    New-ADOrganizationalUnit -Path $ouPath -Name $ou
}
