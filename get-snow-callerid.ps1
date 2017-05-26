if (!$script:ServiceNowCreds)
{
	$script:ServiceNowCreds = Get-Credential
    
}

if(Test-Connection arihant-proxy -Count 1 -Quiet)
{
    $global:PSDefaultParameterValues = @{
        'Invoke-RestMethod:Proxy'='http://arihant-proxy:8080'
        'Invoke-WebRequest:Proxy'='http://arihant-proxy:8080'
        '*:ProxyUseDefaultCredentials'=$true
    }
}

 $uri = 'https://dev17622.service-now.com/api/now/table/incident'

$Body = @{	    
    'sysparm_query' = 'ORDERBYDESCopened_at';
    'state' = '1'
}
 $array = New-Object System.Collections.ArrayList
 $Result = Invoke-RestMethod -Uri $uri -Credential $script:ServiceNowCreds -Body $Body -ContentType "application/json" 
 $property = $Result.result | select -property * 
 foreach($ticketProperty in $property){

    
    $callerIdLink = $ticketProperty.caller_id.link
    $callerUserResult = Invoke-RestMethod -Uri $callerIdLink  -Credential $script:ServiceNowCreds -ContentType "application/json" 
    $callerUserResult.result.name
 }

 <#
 $user_links = $Result.result.caller_id.link

 $username = @()
 foreach($user_link in $user_links){
     $user_result = Invoke-RestMethod -Uri $user_link -Credential $script:ServiceNowCreds -ContentType "application/json" 
     $username += $user_result.result.name
     
 }

 #$username
    #$collect = @()
   
   #$Script:procInfo.GetType()
  # $collection = {$Script:procInfo}.Invoke()
   #$collectData = $collection.Add('caller_id:'+$username)
   ##$array.GetType()
   #[void]$collect.Add($collectData)
   foreach ($user_name in $username){
     $array = New-Object System.Collections.ArrayList 
    $Script:procInfo = $Result.result | select number, short_description, priority, incident_state, impact, active, opened_at, sys_created_on 
   $collect = $array.AddRange($Script:procInfo)
    $users = $array.Add("caller_id:"+$user_name) 
    
   }

   $script:procInfo = $users
   $script:procInfo
   #$list = $array#>
        