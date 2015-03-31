$documentInfo = Get-Content "C:\Users\Panzergrenadier\Desktop\DotNet\916\LogToAnalyze3.txt"
$arrayItem = [System.Collections.ArrayList]@()

#InvokerMethodName
#InvokerClassNam
#StoreProcedureName
#Parameters
foreach($item in $documentInfo){
   $index = $item.IndexOf("Invoker")
   $lenghtOfItem = $item.Length
   $itemSubstracted = $item.Substring($index - 3)
   $jsonTest = ConvertFrom-Json $itemSubstracted   
   $arrayItem.Add($jsonTest)
}
$arrayItem | select InvokerMethodName,StoreProcedureName, InvokerClassName | Sort-Object -Property InvokerMethodName -Unique

