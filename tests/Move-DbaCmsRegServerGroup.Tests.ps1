$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Integration Tests" -Tag "IntegrationTests" {
    Context "Setup" {
        BeforeAll {
            $srvName = "dbatoolsci-server1"
            $group = "dbatoolsci-group1"
            $regSrvName = "dbatoolsci-server12"
            $regSrvDesc = "dbatoolsci-server123"
            
            $newGroup = Add-DbaCmsRegServerGroup -SqlInstance $script:instance1 -Name $group
            $newServer = Add-DbaCmsRegServer -SqlInstance $script:instance1 -ServerName $srvName -Name $regSrvName -Description $regSrvDesc -Group $newGroup.Name
            
            $group2 = "dbatoolsci-group1a"
            $newGroup2 = Add-DbaCmsRegServerGroup -SqlInstance $script:instance1 -Name $group2
            
            $group3 = "dbatoolsci-group1b"
            $newGroup3 = Add-DbaCmsRegServerGroup -SqlInstance $script:instance1 -Name $group3
          }
        AfterAll {
            Get-DbaCmsRegServer -SqlInstance $script:instance1 -Name $regSrvName  | Remove-DbaCmsRegServer -Confirm:$false
            Get-DbaCmsRegServerGroup -SqlInstance $script:instance1 -Group $group, $group2, $group3 | Remove-DbaCmsRegServerGroup -Confirm:$false
        }
        
        It "moves a piped group" {
            $results = $newGroup2, $newGroup3 | Move-DbaCmsRegServerGroup -NewGroup $newGroup.Name
            $results.Parent.Name | Should -Be $newGroup.Name, $newGroup.Name
        }
        
        It "moves a manually specified group" {
            $results = Move-DbaCmsRegServerGroup -SqlInstance $script:instance1 -Group "$group\$group3" -NewGroup Default
            $results.Parent.Name | Should -Be 'DatabaseEngineServerGroup'
        }
    }
}
