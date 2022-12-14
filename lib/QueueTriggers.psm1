function Receive-SlackEvent {
    param( $QueueItem, $TriggerMetadata)

    if (Test-SlackEventSignature -Request $QueueItem) {
        Invoke-ProcessSlackEvent -Request $QueueItem
    }
}

Export-ModuleMember -Function @('Receive-SlackEvent')
