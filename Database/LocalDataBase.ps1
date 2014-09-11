

function Get-Connection()
{
    $json = [System.IO.File]::ReadAllText("$PSScriptRoot\config.json")
    $config = ConvertFrom-Json $json

    $dataSource = $config.configuration.SqlServerName
    $database = $config.configuration.SqlServerDatabase

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connectionString = “Server=$dataSource;Database=$database;Integrated Security=true;”
    $connection.ConnectionString = $connectionString
    return $connection
}

function get-entities($query,$obj)
{
    $connection = Get-Connection
    $connection.open()
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $reader = $command.ExecuteReader()

    $array= @()
    $isObjectDefined = [boolean]$obj


    
    $schemaTable = $reader.GetSchemaTable();
    $columns = $schemaTable.Rows
    $json = ""
    
    if($isObjectDefined -eq $false){ 
        $obj = @{} 
        foreach($col in $columns)
        {
            $obj | Add-Member -type NoteProperty -name $col.ColumnName -value ""
        }
    }

    while($reader.Read())
    {
        $index = 0
        $json = "{"

        foreach($col in $columns)
        {
            if($isObjectDefined)
            {
                Foreach ($Key in ($obj.GetEnumerator() | Where-Object {$_.Key -eq $col.ColumnName}))
                {
                    $value = $reader.GetValue($reader.GetOrdinal($key.Name))
                    $obj[$key.Name] = $value
                }
            }
            else
            {
                $value = $reader.GetValue($reader.GetOrdinal($col.ColumnName))
                $obj[$col.ColumnName] = $value
            }
        }

        $array += $obj
    }

    $connection.close()

    return $array

}

