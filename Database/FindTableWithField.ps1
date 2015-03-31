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


Function GetConnectionString()
{
    $json = [System.IO.File]::ReadAllText("$PSScriptRoot\config.json")
    $config = ConvertFrom-Json $json
    return $config.connectionString
}

Function Getconnection()
{
    $connectionString = GetConnectionString
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    return $connection
}

Function GetDataFromQuery($query)
{
    $connection = Getconnection
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()
    $table = new-object “System.Data.DataTable”
    $table.Load($result)
    $connection.Close()
    return $table
}

Function ExcecuteQuery($query)
{
    $connection = Getconnection
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.ExecuteNonQuery()
    $connection.Close()
}


Function GetDBHasTable($tableName)
{
    $table = GetDataFromQuery “SELECT * FROM sys.databases"

    foreach($row in $table){
        $dbName = $row[0]
        if($dbName -ne "master"){
            $query = “USE " + $dbName + ";SELECT name FROM sys.tables WHERE name like '%"+$tableName+"%';"
            $result = GetDataFromQuery $query
            
            if($result -ne $null){
                $db = [System.String]::Format("{0}",$dbName)
                echo $db
                echo "**********************"
                echo $result
            }
        }
    }
    
}