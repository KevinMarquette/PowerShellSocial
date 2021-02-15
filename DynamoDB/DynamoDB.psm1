#Requires -Module AWS.Tools.DynamoDBv2
using namespace Amazon.DynamoDBv2
using namespace Amazon.DynamoDBv2.Model
using namespace System.Collections.Generic
using namespace System.Collections

function Set-DDItem {
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
                $request.Item[$key] = ConvertTo-DDAttribute -Value $item[$key]
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
            $request.Key[$Key] = ConvertTo-DDAttribute -Value $item

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
            $request.Key[$Key] = ConvertTo-DDAttribute -Value $item

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

function ConvertTo-DDAttribute {
    param($Value)

    process
    {
        switch($Value)
        {
            {$PSItem[0] -is [Bool]} {$type = 'BOOL'}
            {$PSItem[0] -is [Double]} {$type = 'N'}
            {$PSItem[0] -is [Long]} {$type = 'N'}
            {$PSItem[0] -is [Int16]} {$type = 'N'}
            {$PSItem[0] -is [Int32]} {$type = 'N'}
            {$PSItem[0] -is [Int64]} {$type = 'N'}
            Default {$type = 'S'}
        }

        if($Value -is [Array])
        {
            $type = $type + 'S'
        }

        [AttributeValue]@{
            $type=$Value
        }
    }
}


