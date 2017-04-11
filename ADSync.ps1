<#
#################################################################################################
v1.0
Published 11/04/2017
Nathan Michael
Description - this script imports a CSV and populates the AD DEscription based on the server name
populated within the CSV.
#################################################################################################
#>




$Desc=Import-CSV "C:\Cache\Scripts\ServerRecert\Srv_Recert_Remediation.csv"
$Filename=(Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")
$FileLoc=New-Item -ItemType File -Path c:\cache -Name ("Server Recert " + $Filename + ".csv")
$FileOut=@() 
 
# Loop through the array for AD Desc
ForEach ($Guest in $Desc) { 
TRY {
Write-host ********************************************************** -ForegroundColor Green
Write-host Writing Description for $Guest.Name in AD - Please Wait    -ForegroundColor Green
Write-host ********************************************************** -ForegroundColor Green
Set-ADComputer -Identity $Guest.Name -Description $Guest.desc
$Ident=Get-ADComputer -Identity $Guest.name
$TempOut= New-Object System.Object
$TempOut | Add-Member -Type NoteProperty -Name Server -value $Ident.Name
$TempOut | Add-Member -Type NoteProperty -Name Description -value (Get-ADComputer $Ident.Name -Properties *).Description
$FileOut += $TempOut
}
Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {write-host Server $Guest.Name  not found in AD -ForegroundColor Yellow} 
Catch [Microsoft.ActiveDirectory.Management.ADInvalidOperationException] {write-host No description found for server $Guest.Name -ForegroundColor Cyan}
} 
 
$FileOut | Export-Csv $FileLoc -NoTypeInformation
