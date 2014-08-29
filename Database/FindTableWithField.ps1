#Function helper to find the name of a table using a field
$fullPathIncFileName = $MyInvocation.MyCommand.Definition
$currentScriptName = $MyInvocation.MyCommand.Name
$currentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")

Function FindTableWithField($paramField)
{
$fileName = "config.json"
$completeFileName = $currentExecutingPath + $fileName
$configuration = (Get-Content $completeFileName) -join "`n" | ConvertFrom-Json
#I set the data source
$dataSource = $configuration.SqlServerName
$database = $configuration.SqlServerDatabase
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

