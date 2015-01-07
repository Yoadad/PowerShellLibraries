$headerAuthorization = "Basic [base 64 key]"
$logPath = "$PSScriptRoot\log.txt"

function Get-UserData()
{
    $url = "https://www.toggl.com/api/v8/me"
    $r = Invoke-RestMethod -URI $url -Method Get -ContentType $contentType -Headers @{"Authorization"= $headerAuthorization}
    return $r
}

function Send-Entry($description,$date,$duration)
{
    $url = "https://www.toggl.com/api/v8/time_entries"
    $contentType = "application/json"
    $body = '{"time_entry":{"description":"'+$description+'","tags":["billed"],"duration":'+$duration+',"start":"'+$date+'","pid":2304015,"created_with":"powershell-script"}}'
    $r = Invoke-RestMethod -URI $url -Method Post -ContentType $contentType -Body $body -Headers @{"Authorization"= $headerAuthorization}
    $r.data | Add-Content $logPath
}

function get-details($since,$until,$id)
{
    $url = "https://www.toggl.com/reports/api/v2/details?rounding=Off&status=active&user_ids=$id&name=&billable=both&calculate=time&sortDirection=asc&sortBy=date&page=1&project_ids=2304015&description=&since=$since&until=$until&grouping=&subgrouping=time_entries&order_field=date&order_desc=off&distinct_rates=Off&user_agent=Toggl+New+3.2.0&workspace_id=173552&bars_count=31&subgrouping_ids=true&bookmark_token="
    $contentType = "application/json"
    $r = Invoke-RestMethod -URI $url -Method Get -ContentType $contentType -Headers @{"Authorization"= $headerAuthorization}
    return $r
}


function get-entries()
{

    $schedulePath = "$PSSCRIPTROOT\schedule.json"
    $schedule = (Get-Content $schedulePath) -join "`n" | ConvertFrom-Json

    $startDate = get-date ($schedule.since + "T00:00-5:00")
    $endDate = get-date ($schedule.until + "T23:59-5:00")

    $ts = NEW-TIMESPAN –Start $StartDate –End $EndDate
    $totalDays = [System.Math]::Ceiling($ts.TotalDays)

    $entries = @()

    $user = get-userdata

    $details = get-details $schedule.since $schedule.until $user.data.id

    $currentdEntries = $details.data | Select-Object start

    for($i=0;$i -lt $totalDays; $i++)
    {
        $date = $startDate.AddDays($i)
        $isWeekendDay =  $date.DayOfWeek -eq [System.DayOfWeek]::Saturday -or $date.DayOfWeek -eq [System.DayOfWeek]::Sunday
        $isSavingDay = $schedule.nonworkingdays -contains $date.Day

        if(!$isWeekendDay -and !$isSavingDay)
        {
            foreach($item in $schedule.schedule)
            {
                
                $iso = $date.ToString("yyyy-MM-dd") + "T" + $item.start + ":00-05:00"
                $e = $currentdEntries.start -contains $iso.ToString()

                if(!$e)
                {
                    $description = $schedule.tasks | where {$_.id -eq $item.taskid} | Select-Object -Index 0
                    $entries += @{date=$iso;description=$description.description;duration=$item.duration}
                }
            }
        }
    }

    return $entries
}


function set-entries()
{
    New-Item $logPath -type file -force

    $entries = get-entries

    $i = 0
    foreach($item in $entries)
    {
        send-entry $item.description $item.date $item.duration
        $i = $i + 1
        echo $i
    }
}
