$k=Import-Csv "C:\Users\Administrator\Desktop\Book1.csv"
foreach($l in $k)
{
$machineName=$l.ComputerName
$user = $l.Username
$spec= $l.Specification
if (Test-Connection -ComputerName $machineName -Count 1 -Quiet)
{
if($spec -eq "Local")
{
$objGroup = [ADSI]("WinNT://$machineName/administrators,group")
$objGroup
$objGroup.psbase.Invoke("add",([ADSI]"WinNT://$machineName/$user").path)
Write-Host "$user local user is removing from $machineName" -ForegroundColor Green
}
else
{
$domain="exchange.local"
$objGroup = [ADSI]("WinNT://$machineName/administrators,group")
$objGroup.psbase.Invoke("add",([ADSI]"WinNT://$domain/$user").path)
Write-Host "$user Domain user is add from $machineName" -ForegroundColor Green
}
}
else
{
"$machineName is not connecting" >> notconnecting.txt
}
} 


