Param([Parameter(Mandatory=$true)]
	[string]$stduser
	)

$Logname = "BupaInfra"
$LogSource = "Bupa_Automation"

Function BupaEvent ([String]$BEMessage,[String]$BESeverity = "Information", [int]$BEID = 0){
    Write-EventLog -LogName $LogName -EntryType $BESeverity -EventId $BEID -Source $LogSource -Message $BEMessage
}

#Get the user account from AD
$ADUser = get-aduser $stduser -Properties Mail -Server internal.bupa.com.au
if ($ADuser.count -ne 1)
    {
    BupaEvent "Error creating Admin account, account error" Warning
    Write-output "error in account count"
    break
    }
[string]$AdminUser = $stduser+"-admin"
#Create new user


New-ADUser -Name $AdminUser -City $ADUser.city -Description "testing runbook from Azure on premises" -Enabled $true -Manager $ADuser.manager -SamAccountName $AdminUser -Surname $ADuser.surname -Title $ADUser.title -Path "OU=Admin,OU=Accounts,OU=Service Objects,DC=internal,DC=bupa,DC=com,DC=au" -ErrorVariable ADmincreateerr -ChangePasswordAtLogon $true -Server internal.bupa.com.au -PasswordNotRequired $true
Set-ADAccountPassword -Identity $aduser -Reset -NewPassword (ConvertTo-SecureString "Password.........." -force -AsPlainText) -Server internal.bupa.com.au


if($admincreateerr -eq $null)
    {
    BupaEvent "Created new admin account $Adminuser successfully"
    }
Else
    {
    BupaEvent "Error occurred while creating new admin account $Adminuser `n $admincreateerr"
    }

Send-MailMessage -SmtpServer "mail1.internal.bupa.com.au" -Subject "Your admin account password" -To $ADUser.mail-Body "Your temporary password is Password1.......... `n Please login and change this within the next 24 hours" -From "PowershellGods@bupa.com.au"