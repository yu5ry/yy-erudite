Function Get-ServerAdmins {
    <#
        Get members of local Administrators group. Custom function created due to Get-LocalGroupMember cmdlet availability only for Powershell 5.1 and above not available in older OSes.
        Author: Azwan Abd Satar

        This PoSh script was derived from https://github.com/ExxonMobil/Win-SRV-PoSH/blob/f4c1d4ad65ed0b3574028c35f6ca981f117456a1/Win-SRV-User/Win-SRV-User.ps1#L221 and tweaked to work on multiple remote servers.
    #>
     [Cmdletbinding()]
    Param(
    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [String[]]$ComputerName =  $Env:Computername
    )

    $LocalAdmins = @()
    ForEach($Computer in $ComputerName){    
        $computerObj = [ADSI]("WinNT://" + $Computer + ",computer")
        $groupObj = $computerObj.psbase.children.find("Administrators")
        $members = @()
        $members = @($groupObj.psbase.Invoke("Members")) | ForEach-Object { 
                $path = ([ADSI]$_).InvokeGet("ADsPath")
                If($path -imatch $Computer -or $path -imatch 'NT SERVICE' -or $path -imatch 'NT AUTHORITY'){
                    $PrincipalSource = "Local"
                    }
                Else{$PrincipalSource = "ActiveDirectory"}
                $name = ([ADSI]$_).InvokeGet("Name")
                $class = ([ADSI]$_).InvokeGet("Class")
                $member = [PSCustomObject]@{
                    ComputerName = $Computer
                    Name = $name
                    Path = $path 
                    ObjectClass = $class
                    PrincipalSource = $PrincipalSource
                }
                return $member        
        }
        $LocalAdmins += $members
    }
    Return $LocalAdmins
}
