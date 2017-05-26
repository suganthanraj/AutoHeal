
if(Test-Connection arihant-proxy -Count 1 -Quiet)
{
    $global:PSDefaultParameterValues = @{
        'Invoke-RestMethod:Proxy'='http://arihant-proxy:8080'
        'Invoke-WebRequest:Proxy'='http://arihant-proxy:8080'
        '*:ProxyUseDefaultCredentials'=$true
    }
}
$username = "admin"
$password = "Sugu@raj90"
$instance="dev17622" 
<#$Values=@{
       'caller_id'='79dc05a14f223200dcedc4b18110c709';
       'short_description'='nopeeeeeeeeeeeeeee';
       'category'='inquiry';
       'impact' = '3';
       'active' = 'true';
       'priority' = '5';
       'sys_Created_by' = 'admin';
            }#>
$header=@{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$password))}
$Body = @{
	    'state' = '1'
    }
$Result= Invoke-RestMethod -Uri https://$instance.service-now.com/api/now/table/incident -Method Get -Body $Body -Headers $header -ContentType "Application/json"
foreach ($tickets in $Result){
    write-host "Ticket Number"$tickets.result.number
    write-host "opened at"$tickets.result.opened_at
    write-host "created on"$tickets.result.sys_created_on
}
