clear
$score = 0
while($true){
    
    $sm = [System.String]::Format("Score: {0}", $score)
    echo $sm

    $x = Get-Random -Maximum 12 -Minimum 1
    $y = Get-Random -Maximum 12 -Minimum 1
    $m = [System.String]::Format("{0} x {1} = ?",$x,$y)
    $r = $x*$y

    echo $m
    #echo $r

    $ur = Read-Host 'Respuesta'
    
    clear

    if ($ur -eq $r){
        echo '¡¡Muy bien!! :)'
        $score++
    }
    else{
        echo '¡¡Necesitas estudiar mas!! :('
        $score--
    }

   
}