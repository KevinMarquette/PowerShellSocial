Import-Module AWS.Tools.DynamoDBv2 -Force

New-DDBTable  -TableName PowerShell -Schema

Get-help New-DDBTable -Examples

$schema = New-DDBTableSchema
$schema | Add-DDBKeySchema -KeyName "ComputerName" -KeyDataType "S"
$schema | New-DDBTable -TableName "PowerShellTable" -ReadCapacity 10 -WriteCapacity 5

Get-DDBTable -TableName PowerShellTable
Remove-DDBTable -TableName PowerShellTable

$config = [AmazonDynamoDBConfig
$client = [Amazon.PowerShell.Cmdlets.DDB.AmazonDynamoDBClientCmdlet]::new()
[Reflection.Assembly]::LoadFile('C:\Users\kemarqu\Documents\PowerShell\Modules\AWS.Tools.DynamoDBv2\4.1.8.0\AWSSDK.DynamoDBv2.dll')



using namespace Amazon.DynamoDBv2
using namespace Amazon.DynamoDBv2.Model
using namespace System.Collections.Generic
using namespace System.Collections

function Put-DDItem {
    param(
        [String]
        $TableName,

        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    begin
    {
        $client = [AmazonDynamoDBClient]::new()
    }

    process
    {
        foreach($item in $InputObject)
        {
            $request = [PutItemRequest]::new()
            $request.TableName = $TableName
            $request.Item = [Dictionary[string,AttributeValue]]::new()

            Write-Debug 'Convert Object to Hashtable'
            $hashtable = [ordered]@{}
            if($item -isnot [IDictionary])
            {
                foreach($property in $item.PSObject.Properties)
                {
                    $hashtable[$property.name] = $property.value
                }
                $item = $hashtable
            }

            Write-Debug 'Convert Hashtable to AttributeValue'
            foreach($key in $item.Keys)
            {
                if([double])
                $request.Item[$key] = [AttributeValue]@{
                    S=$item[$key]
                }
            }

            Write-Debug 'Adding item to DyanmoDB'
            $result = $client.PutItemAsync($request)
            $result.Result | out-null
        }
    }
}



function Get-DDItem
{
    param
    (
        [String]
        $TableName,

        [Parameter()]
        $Key,

        [Parameter(ValueFromPipeline)]
        $Value
    )

    begin
    {
        $client = [AmazonDynamoDBClient]::new()
    }

    process
    {
        foreach($item in $Value)
        {
            $request = [GetItemRequest]::new()
            $request.TableName = $TableName
            $request.Key = [Dictionary[string,AttributeValue]]::new()
            $request.Key[$Key] = [AttributeValue]::new()
            $request.Key[$Key].S = $Value

            $result = $client.GetItemAsync($request)

            $returnObject = [ordered]@{}
            foreach($node in $result.Result.Item.GetEnumerator())
            {
                $returnObject[$node.Key] = $node.Value.S
            }

            [pscustomobject]$returnObject
        }
    }
}


function Remove-DDItem
{
    param
    (
        [String]
        $TableName,

        [Parameter()]
        $Key,

        [Parameter(ValueFromPipeline)]
        $Value
    )

    begin
    {
        $client = [AmazonDynamoDBClient]::new()
    }

    process
    {
        foreach($item in $Value)
        {
            $request = [DeleteItemRequest]::new()
            $request.TableName = $TableName
            $request.Key = [Dictionary[string,AttributeValue]]::new()
            $request.Key[$Key] = [AttributeValue]::new()
            $request.Key[$Key].S = $Value

            $result = $client.DeleteItemAsync($request)
            $result.Result | out-null
        }
    }
}


function Invoke-DDScan
{
    param
    (
        [String]
        $TableName
    )

    begin
    {
        $client = [AmazonDynamoDBClient]::new()
    }

    process
    {
        $request = [ScanRequest]::new()
        $request.TableName = $TableName

        $result = $client.ScanAsync($request)

        Write-Verbose "Query results count [$($result.Result.Items.Count)]"
        foreach($row in $result.Result.Items)
        {
            $returnObject = [ordered]@{}
            foreach($node in $row.GetEnumerator())
            {
                $returnObject[$node.Key] = $node.Value.S
            }

            [pscustomobject]$returnObject
        }

    }
}

Put-DDItem $TableName ([pscustomobject]@{
    ComputerName = "TestFour"
    Description = "double update"
})

Put-DDItem -TableName $TableName -InputObject @{
    ComputerName = 'TestFive'
    Description = 'double update'
}

$results = Get-DDItem -TableName $TableName -Key "ComputerName" -Value "TestFive"
$results

Remove-DDItem -TableName $TableName -Key "ComputerName" -Value "TestFive"

Invoke-DDScan -TableName $TableName -Verbose



$h = @{a=1}
foreach($item in $h.GetEnumerator())
{
    "value is $($item.value)"
}


$TableName = "PowerShellTable"
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new()
$putItemRequest = [Amazon.DynamoDBv2.Model.PutItemRequest]::new()
$putItemRequest.TableName = $TableName
$putItemRequest.Item = [System.Collections.Generic.Dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]]::new()


$putItemRequest.Item["ComputerName"] = [Amazon.DynamoDBv2.Model.AttributeValue]@{
    S="TestTwo"
}



$result = $client.PutItemAsync($putItemRequest)


$TableName = "PowerShellTable"
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new()
$getItemRequest = [Amazon.DynamoDBv2.Model.GetItemRequest]::new()
$getItemRequest.TableName = $TableName
$getItemRequest.Key  = [System.Collections.Generic.Dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]]::new()
$getItemRequest.Key["ComputerName"] = [Amazon.DynamoDBv2.Model.AttributeValue]::new()
$getItemRequest.Key["ComputerName"].S = "TestTwo"

$result = $client.GetItemAsync($getItemRequest)



$TableName = "PowerShellTable"
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new()
$request = [Amazon.DynamoDBv2.Model.ScanRequest]::new()
$request.TableName = $TableName
$result = $client.ScanAsync($request)








