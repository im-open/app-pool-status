Param(
    [parameter(Mandatory = $true)]
    [string]$server,
    [parameter(Mandatory = $true)]
    [string]$app_pool_name,
    [parameter(Mandatory = $true)]
    [string]$user_id,
    [parameter(Mandatory = $true)]
    [SecureString]$password
)

$display_action = 'App Pool Status'
$display_action_past_tense = "$display_action Returned"

$credential = [PSCredential]::new($user_id, $password)
$so = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck

Write-Output "Importing remote server cert..."
Import-Certificate -Filepath $cert_path -CertStoreLocation 'Cert:\LocalMachine\Root'

$script = {
    $app_pool = Get-IISAppPool -Name $Using:app_pool_name
    return $($app_pool.State)
}

$result = Invoke-Command -ComputerName $server `
    -Credential $credential `
    -UseSSL `
    -SessionOption $so `
    -ScriptBlock $script

"app-pool-status=$result" >> $env:GITHUB_OUTPUT

Write-Output "IIS $display_action_past_tense."
