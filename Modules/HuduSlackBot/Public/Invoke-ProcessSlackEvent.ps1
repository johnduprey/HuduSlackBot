function Invoke-ProcessSlackEvent {
    Param(
        $Request
    )

    # Query for existing event and cancel if already processed
    $EventQuery = @{
        TableName    = 'SlackPayloads'
        PartitionKey = 'events'
        RowKey       = $Request.Body.event_id
    }
    $Existing = Get-SlackBotData @EventQuery
    if ($Existing.RowKey -eq $Request.Body.event_id) {
        Write-Host 'Request already exists'
        return $false
    }

    # Initialize Slack config
    Import-Module PSSlack
    Set-PSSlackConfig -Token $env:SlackBotToken -NoSave
    
    # Process event
    $SlackEvent = $Request.Body
    switch ($SlackEvent.event.type) {
        'link_shared' {
            Get-SlackLinkUnfurl -SlackEvent $SlackEvent
        }

        'app_home_opened' {
            Get-SlackAppHome -SlackEvent $SlackEvent
        }
    }


    # Save event data to prevent duplicates
    $TableRow = @{
        EventType = $Request.Body.event.type
    }
    if ($env:SlackLogPayloads) { $TableRow.Payload = $Request.RawBody }
    
    $EventQuery.TableRow = $TableRow 
    Set-SlackBotData @EventQuery
}
