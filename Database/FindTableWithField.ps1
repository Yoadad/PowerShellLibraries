#Function helper to find the name of a table using a field
$fullPathIncFileName = $MyInvocation.MyCommand.Definition
$currentScriptName = $MyInvocation.MyCommand.Name
$currentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")

Function FindTableWithField($paramField)
{

    #Read Configuration
    $json = [System.IO.File]::ReadAllText("$PSScriptRoot\config.json")
    $config = ConvertFrom-Json $json

    $dataSource = $config.configuration.SqlServerName
    $database = $config.configuration.SqlServerDatabase
    $connectionString = “Server=$dataSource;Database=$database;Integrated Security=true;”
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString


    #Open the connection
    $connection.Open()

    #I define the query
    $query = “SELECT columns.name AS ColName, tables.name as TableName FROM sys.columns AS columns"
    $query += " INNER JOIN sys.tables AS tables ON columns.object_id = tables.object_id WHERE columns.name LIKE '%$paramField%'" 

    $command = $connection.CreateCommand()
    $command.CommandText = $query

    $result = $command.ExecuteReader()

    #Load the result into a datatable
    $table = new-object “System.Data.DataTable”
    $table.Load($result)

    $table
    $connection.Close()
}

