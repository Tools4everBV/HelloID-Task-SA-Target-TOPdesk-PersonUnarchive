# TOPdesk-Task-SA-Target-TOPdesk-PersonUnarchive
###########################################################
# Form mapping
$userId = $form.id
$userDisplayName = $form.displayName

try {
    Write-Information "Executing TOPdesk action: [UnarchivePersonAccount] for: [$($userDisplayName)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with TOPdesk API key
    $pair = "${topdeskApiUsername}:${topdeskApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{
        "authorization" = $Key
        "Accept"        = "application/json"
    }

    Write-Verbose "Unarchiving TOPdesk Person for: [$($userDisplayName)]"
    $splatUnarchiveUserParams = @{
        Uri         = "$($topdeskBaseUrl)/tas/api/persons/id/$($userId)/unarchive"
        Method      = "PATCH"
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json; charset=utf-8"
    }
    $response = Invoke-RestMethod @splatUnarchiveUserParams

    $auditLog = @{
        Action            = "EnableAccount"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$response.id
        TargetDisplayName = [String]$response.dynamicName
        Message           = "TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "EnableAccount"
        System            = "TOPdesk"
        TargetIdentifier  = ""
        TargetDisplayName = [String]$userDisplayName
        Message           = "Could not execute TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)]"
        Write-Error "Could not execute TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute TOPdesk action: [EnablePersonAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
}
###########################################################