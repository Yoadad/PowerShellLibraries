clear

$XL = New-Object -comobject Excel.Application
$XL.Visible = $False

$WB = $XL.Workbooks.Open("D:\PowerShell\Training\test.xlsx")
$WS = $WB.Worksheets.Item(1)

$cell = $WS.Cells.Item(2,5)

echo $cell.Text
echo $cell.Formula
