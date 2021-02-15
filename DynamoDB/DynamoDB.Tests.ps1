Describe 'DynamoDB' {
    It 'Should not throw' {

        Set-DDItem $TableName ([pscustomobject]@{
            ComputerName = "TestFour"
            Description = "double update"
        })

        Set-DDItem -TableName $TableName -InputObject @{
            ComputerName = 'TestFive'
            Description = 'double update'
        }

        $results = Get-DDItem -TableName $TableName -Key "ComputerName" -Value "TestFive"
        $results

        Remove-DDItem -TableName $TableName -Key "ComputerName" -Value "TestFive"

        Invoke-DDScan -TableName $TableName -Verbose

    }

    It 'Does something' {

    }
}
