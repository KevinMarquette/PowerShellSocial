Import-Module AWS.Tools.DynamoDBv2 -Force

New-DDBTable  -TableName PowerShell -Schema

Get-help New-DDBTable -Examples

$schema = New-DDBTableSchema
$schema | Add-DDBKeySchema -KeyName "ComputerName" -KeyDataType "S"
$schema | New-DDBTable -TableName "PowerShellTable" -ReadCapacity 10 -WriteCapacity 5

Get-DDBTable -TableName PowerShellTable
Remove-DDBTable -TableName PowerShellTable




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
$getItemRequest.Key = [System.Collections.Generic.Dictionary[string,Amazon.DynamoDBv2.Model.AttributeValue]]::new()
$getItemRequest.Key["ComputerName"] = [Amazon.DynamoDBv2.Model.AttributeValue]::new()
$getItemRequest.Key["ComputerName"].S = "TestTwo"

$result = $client.GetItemAsync($getItemRequest)



$TableName = "PowerShellTable"
$client = [Amazon.DynamoDBv2.AmazonDynamoDBClient]::new()
$request = [Amazon.DynamoDBv2.Model.ScanRequest]::new()
$request.TableName = $TableName
$result = $client.ScanAsync($request)
