function Get-WmiHadr {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$Credential,
        [Alias('Silent')]
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {

            try {
                $computer = $computerName = $instance.ComputerName
                $instanceName = $instance.InstanceName
                $currentState = Invoke-ManagedComputerCommand -ComputerName $computerName -ScriptBlock { $wmi.Services[$args[0]] | Select-Object IsHadrEnabled } -ArgumentList $instanceName -Credential $Credential
            } catch {
                Stop-Function -Message "Failure connecting to $computer" -Category ConnectionError -ErrorRecord $_ -Target $instance
                return
            }

            if ($null -eq $currentState.IsHadrEnabled) {
                $isenabled = $false
            } else {
                $isenabled = $currentState.IsHadrEnabled
            }
            [PSCustomObject]@{
                ComputerName  = $computer
                InstanceName  = $instanceName
                SqlInstance   = $instance.FullName
                IsHadrEnabled = $isenabled
            }
        }
    }
}