
Function SendEntry($url,$description,$year,$month,$day,$hour,$duration)
{
    $headerAuthorization = "Basic [token 64 base]"
    $contentType = "application/json"
    $body = '{"time_entry":{"description":'+$description+',"tags":["billed"],"duration":'+$duration+',"start":"'+$year+'-'+$month+'-'+$day+'T'+$hour+':00-05:00","pid":2304015}}'

    $r = Invoke-RestMethod -URI $url -Method Post -ContentType $contentType -Body $body -Headers @{"Authorization"= $headerAuthorization}
    $r.data | Add-Content .\response.txt
}



clear

$url = "https://www.toggl.com/api/v8/time_entries"
                                                                                                        
"" | Out-File .\response.txt

#días del mes
$days = 15,17,18,19

#tareas
$scrum = '"Daily SCRUM"'
$ui = '"CAT (PetroSkills) Compass UI Globalization"'

foreach($day in $days)
{
    $d = [System.String]::Format("{0:0#}",$day)
    $m = '09'
    $y = '2014'
    
    SendEntry $url $ui $y $m $d '08:00' '18000'
    SendEntry $url $ui $y $m $d '14:00' '5400'
    SendEntry $url $scrum $y $m $d '15:30' '900'
    SendEntry $url $ui $y $m $d '08:00' '4500'
}
