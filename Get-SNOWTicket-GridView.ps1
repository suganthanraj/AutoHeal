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

function Set-SNOWTicket {
    $uri = 'https://dev17622.service-now.com/api/now/table/incident'

    $Body = @{	    
        'sysparm_query' = 'ORDERBYDESCopened_at';
        'state' = '1'
    }

   
    try{
        Add-Type -Path "C:\Program Files (x86)\MySQL\MySQL Connector Net 6.9.9\Assemblies\v4.5\MySql.Data.dll"
        $MySQLAdminUserName = 'root'
        $MySQLAdminPassword = ''
        $MySQLDatabase = 'dc_autoheal'
        $MySQLHost = 'localhost'
        $ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase

        [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
        $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
        $Connection.ConnectionString = $ConnectionString
        $Connection.Open()

        $MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand

        $MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter

        $MYSQLDataSet = New-Object System.Data.DataSet

        $MYSQLCommand.Connection=$Connection

        $Result = Invoke-RestMethod -Uri $uri -Credential $script:ServiceNowCreds -Body $Body -ContentType "application/json" 
    
         for ($i=0; $i -lt $Result.result.Length; $i++){
           foreach ($tickets in $Result){
      
                $ticket_number = $tickets.result.number[$i]
                $ticket_opened_at = $tickets.result.opened_at[$i]
                $ticket_description = $tickets.result.short_description[$i]
                $ticket_created_on = $tickets.result.sys_created_on
                # $MYSQLCommand.CommandText="INSERT INTO dc_snow_tickets (tkt_number,tkt_opened_at,tkt_description) VALUES ('$($ticket_number)','$($ticket_opened_at)','$($ticket_description)')"
                $MYSQLCommand.CommandText= "INSERT INTO dc_snow_tickets (tkt_number,tkt_created_on,tkt_opened_at,tkt_description,tkt_status) SELECT * FROM (SELECT '$($ticket_number)','$($ticket_created_on)','$($ticket_opened_at)','$($ticket_description)',0) AS tmp WHERE NOT EXISTS (SELECT tkt_number FROM dc_snow_tickets WHERE tkt_number = '$($ticket_number)')"
                $MYSQLDataAdapter.SelectCommand=$MYSQLCommand
                $MYSQLDataAdapter.Fill($MYSQLDataSet) 
                #$MYSQLCommand.ExecuteNonQuery()
            }
        
        }
           
    }
    Catch {
        Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
        }

    $Connection.Close()
}


<#function Solve-SNOWIncident { 
    
    $uri = 'https://dev17622.service-now.com/api/now/table/incident'

    $Body = @{	    
        'sysparm_query' = 'ORDERBYDESCopened_at';
        'state' = '1'
    }

    
    try {

      
        $result = Invoke-RestMethod -Uri $uri -Credential $script:ServiceNowCreds -Body $Body -ContentType "application/json" 
    
        $array = New-Object System.Collections.ArrayList 
        $Script:procInfo = $result.result | select number, short_description, priority
	    
       
        $script:procInfo
        <#$ticketDescription = $ticketDescriptionRow
                
        $ScriptToRun=$PSScriptRoot+"goodbye.ps1 -description $ticketDescription"

        &$ScriptToRun 

        start-sleep 60#>
       
       

    <#} catch{
        write-host "Resolving SNOW ticket disConnected"
    }
 
}
#>
function Get-SNOWIncident { 
    
    $uri = 'https://dev17622.service-now.com/api/now/table/incident'

    $Body = @{	    
        'sysparm_query' = 'ORDERBYDESCopened_at';
        'state' = '1'
    }

    
    try {

      
        $result = Invoke-RestMethod -Uri $uri -Credential $script:ServiceNowCreds -Body $Body -ContentType "application/json" 
    
         <#$user_links = $result.result.caller_id.link

         $username = @()
         foreach($user_link in $user_links){
             $user_result = Invoke-RestMethod -Uri $user_link -Credential $script:ServiceNowCreds -ContentType "application/json" 
             $username += $user_result.result.name
     
         }
         #>
        $array = New-Object System.Collections.ArrayList 
        $Script:procInfo = $result.result | select number, short_description, priority, incident_state, impact, active, opened_at, sys_created_on ,caller_id
       
	    $array.AddRange($Script:procInfo)
       
    
	
        $ticketDataGrid.DataSource = $array
       
        foreach ($ticketDataGridRow in $ticketDataGrid.Rows)
        {
           
            
            $ticketDataGridRowType = $ticketDataGridRow.Cells[2].Value.ToString();
            
            
             #Write-Progress "Fetching Ticket from SNOW Ticketing Tool" -PercentComplete (($ticketDataGridRow.count) * 100)
             #Start-Sleep -Milliseconds 50
            if ($ticketDataGridRowType -eq '5')
            {
                $ticketDataGridRow.DefaultCellStyle.BackColor = "Red";
                $ticketDataGridRow.DefaultCellStyle.ForeColor = "White";
            }
            elseif ($ticketDataGridRowType -eq '4')
            {
                $ticketDataGridRow.DefaultCellStyle.BackColor = "Yellow";
                $ticketDataGridRow.DefaultCellStyle.ForeColor = "Black";
            }
            elseif ($ticketDataGridRowType -eq '3')
            {
                $ticketDataGridRow.DefaultCellStyle.BackColor = "Cyan";
                $ticketDataGridRow.DefaultCellStyle.ForeColor = "Black";
            }
            elseif ($ticketDataGridRowType -eq '2')
            {
                $ticketDataGridRow.DefaultCellStyle.BackColor = "Green";
                $ticketDataGridRow.DefaultCellStyle.ForeColor = "Black";
            }
            elseif ($ticketDataGridRowType -eq '1')
            {
                $ticketDataGridRow.DefaultCellStyle.BackColor = "White";
                $ticketDataGridRow.DefaultCellStyle.ForeColor = "Black";
            }
        }

        $ticketDataGrid.AutoResizeColumns( "AllCells" )

    } catch{
        write-host "SNOW NOT Connected"
    }
 
   
} 

#Generated Form Function 
function GenerateForm { 
    ######################################################################## 
    # Code Generated By: SAPIEN Technologies PrimalForms (Community Edition) v1.0.8.0 
    # Generated On: 2/24/2010 11:38 AM 
    # Generated By: Ravikanth Chaganti (http://www.ravichaganti.com/blog) 
    ######################################################################## 
 
    #region Import the Assemblies 
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null 
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null 
    #endregion 
 
    #region Generated Form Objects 
    $ticketForm = New-Object System.Windows.Forms.Form 
    $ticketFormLabel = New-Object System.Windows.Forms.Label 
    $frmCloseBtn = New-Object System.Windows.Forms.Button 
    
    $ticketDataGrid = New-Object System.Windows.Forms.DataGridView
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState 
    $timer = New-Object System.Windows.Forms.Timer
    #endregion Generated Form Objects 
 
    #---------------------------------------------- 
    #Generated Event Script Blocks 
    #---------------------------------------------- 
    #Provide Custom Code for events specified in PrimalForms. 
    $frmCloseBtn_OnClick=  
    { 
        $ticketForm.Close() 
    } 
 
    $OnLoadForm_UpdateGrid= 
    { 
        
        Get-SNOWIncident
    }
    
    $OnLoadForm_UpdateDB=
    {
        Set-SNOWTicket
    } 
 
    #---------------------------------------------- 
    #region Generated Form Code 
    $ticketForm.Text = "DC AUTO HEAL" 
    $ticketForm.Name = "DC AUTO HEAL" 
    $ticketForm.DataBindings.DefaultDataSourceUpdateMode = 0 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 1020
    $System_Drawing_Size.Height = 650 
    $ticketForm.ClientSize = $System_Drawing_Size 
 
    $ticketFormLabel.TabIndex = 4 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 155 
    $System_Drawing_Size.Height = 23 
    $ticketFormLabel.Size = $System_Drawing_Size 
    $ticketFormLabel.Text = "SNOW Ticket Manager" 
    $ticketFormLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,2,3,0) 
    $ticketFormLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,0,102,204)  
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 13 
    $System_Drawing_Point.Y = 13 
    $ticketFormLabel.Location = $System_Drawing_Point 
    $ticketFormLabel.DataBindings.DefaultDataSourceUpdateMode = 0 
    $ticketFormLabel.Name = "label1"  
    $ticketForm.Controls.Add($ticketFormLabel) 
 
   $frmCloseBtn.TabIndex = 6 
   $frmCloseBtn.Name = "button3" 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 75 
    $System_Drawing_Size.Height = 23 
   $frmCloseBtn.Size = $System_Drawing_Size 
   $frmCloseBtn.UseVisualStyleBackColor = $True  
   $frmCloseBtn.Text = "Close" 
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 629 
    $System_Drawing_Point.Y = 578 
   $frmCloseBtn.Location = $System_Drawing_Point 
   $frmCloseBtn.DataBindings.DefaultDataSourceUpdateMode = 0 
   $frmCloseBtn.add_Click($button3_OnClick)  
    $ticketForm.Controls.Add($button3) 
 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 1120
    $System_Drawing_Size.Height = 650 
    $ticketDataGrid.Size = $System_Drawing_Size 
    $ticketDataGrid.DataBindings.DefaultDataSourceUpdateMode = 0 
    #$ticketDataGrid.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0) 
    $ticketDataGrid.Name = "dataGrid1" 
    $ticketDataGrid.DataMember = "" 
    $ticketDataGrid.TabIndex = 0 
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 13 
    $System_Drawing_Point.Y = 48 
    $ticketDataGrid.Location = $System_Drawing_Point 
    $ticketDataGrid.ReadOnly = $true
    $ticketForm.Controls.Add($ticketDataGrid) 
 
    #endregion Generated Form Code 
 
    #Save the initial state of the form 
   # $InitialFormWindowState = $ticketForm.WindowState 
    $timer.Interval = 120000  # once per second
    $timer.Add_Tick($OnLoadForm_UpdateGrid)
    $timer.Add_Tick($OnLoadForm_UpdateDB)


    # Finally
    $timer.Start()
    #Add Form event 
    $ticketForm.add_Load($OnLoadForm_UpdateGrid) 
    $ticketForm.add_Load($OnLoadForm_UpdateDB) 
    
    #Show the Form 
    $ticketForm.ShowDialog()| Out-Null 
     $ticketForm.Dispose()
 } #End Function 

 
#Call the Function 

GenerateForm

#Solve-SNOWIncident
