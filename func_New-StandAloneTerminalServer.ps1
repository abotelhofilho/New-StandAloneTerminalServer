function New-StandAloneTerminalServer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)] [string] $ServerActiveDirectoryFQDN,
        [Parameter(Mandatory = $true)] $KMS,
        [Parameter(Mandatory = $false)] [string] $CollectionName = "$ServerActiveDirectoryFQDN", # default uses server AD FQDN,
        [Parameter(Mandatory = $false)] [string] $CollectionDescription = "$ServerActiveDirectoryFQDN", # default uses server AD FQDN
        [Parameter(Mandatory = $false)] $RDLicenseMode = "PerUser" # default
    )
    ## Import Remote Desktop module
    Import-Module RemoteDesktop
    ## Set server variable
    $Server = $ServerActiveDirectoryFQDN
    ## Set Local Server variable
    $LocalServer = $env:computername + "." + $env:userdnsdomain
    
    Write-Host "This WILL cause the remote server to reboot" -BackgroundColor Red -ForegroundColor Black

    ## Local Server Check
    If ( $Server -eq $LocalServer ) {

        Write-Host "This can not be run locally.  The RDS-Connection-Broker role won't install when running the setup locally. Run this from a remote server." -BackgroundColor Red -ForegroundColor Yellow

    }
    else {
            
        ## Command below adds all the necessary roles for a single stand alone Terminal Server.
        ## This needs to be run from a remote server, can not be run locally, it errors when it tries to add the Connection Broker role
        New-RDSessionDeployment -ConnectionBroker $Server -WebAccessServer $Server -SessionHost $Server
        #New-RDSessionDeployment –ConnectionBroker $Server –WebAccessServer $Server -SessionHost $Server

        ## If this command fails for any reason remotely, run it locally
        # New-RDSessionCollection –CollectionName $Server –SessionHost $Server –CollectionDescription $Server -ConnectionBroker $Server
        New-RDSessionCollection -CollectionName $CollectionName -SessionHost $Server -CollectionDescription $CollectionDescription -ConnectionBroker $Server

        Set-RDLicenseConfiguration -LicenseServer $KMS -Mode $RDLicenseMode -ConnectionBroker $Server -Force
        #Add-RDServer -Server $KMS -Role RDS-LICENSING -ConnectionBroker $Server
    
    }
    
}
