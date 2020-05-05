$d6set = @{}
function Roll-Die ([int] $Die, [int] $plural = 1) {
    $dset = @()
    for ($i = 1; $i -le $plural; $i++){
        $rolls = @()
        $tries = 0
        do {
            $dice = Get-Random -Minimum 1 -Maximum ($Die+1)
            $rolls += $dice
        } while (($dice -lt 2) -and ($rolls.count -lt 3) )
         $roll = New-Object -TypeName PSObject -Property @{
         'Outcomes' = $rolls -join( "->")
         'RollCount' = $rolls.length
         'Result' = $dice
         }

        $dset += $roll
    }
    return $dset
}

function RollDice {
$rolls = @()
$tries = 0
do {
$dice = Get-Random -Minimum 1 -Maximum 7
$rolls += $dice
}
while (($dice -le 2) -and ($rolls.count -lt 3) )
return $dice
}
#$d6set[1] = RollDice
#$d6set[2] = RollDice
#$d6set[3] = RollDice
#$d6set[4] = RollDice
#($d6set.Values | sort | select -First 3| measure -Sum).Sum
function get-PointCost ($ability = 8) {
#$fib
$multiplier = $ability - 8
$offset = [math]::Sqrt($multiplier*$multiplier)
$fibacc = Get-FibAcc $offset
if ($multiplier -lt 0) {$negate = -1}
else {$negate = 1}
return [math]::Round(((($fibacc*$negate)+($multiplier*15))/16))
}
Function Get-FibAcc ($n) {

$accumulate = 0
    $current = 0
    $previous = 1;
    for ($i = 0; $i -lt $n; $i++){
    #while ($current -lt $n) {
        #$current;
        $current,$previous = ($current + $previous),$current
        $accumulate += $current
    }
    return $accumulate
 }

function get-abilities {
    $abilities = @()
    for ($r=1; $r -le 6; $r++){
        $data = (Roll-Die 6 4)
        $outcome = (($data | sort result -Descending | select -First 3 ) | measure result -sum).sum
        $ability =  New-Object -TypeName PSObject -Property @{
            "DiceRolls" = $data.outcomes -join(", ")
            "RollCount" = ($data| measure rollcount -sum).sum
            "Outcome" =  $outcome
            "RawMod" = ($outcome - 10)/2
            "Modifier" = [math]::Truncate((($outcome - 10)/2))
            "PointCost" = get-PointCost $outcome
        }
        $abilities += $ability
    }
    return $abilities
}
#$ability = $data | sort result -Descending | select -First 3 
function collate-abilities ($itterations = 1000) {
    $collation =@()
    for ($it=1; $it -le $itterations; $it++){
        show-abilities
        $collation += $colitem
    }
    return $collation

}
function show-abilities {
    $coldata = get-abilities
    $measuremod = ($coldata | measure rawmod -Sum -Minimum -Maximum -Average)
    $cost = ($coldata | measure pointcost -Sum)
    $colitem =  New-Object -TypeName PSObject -Property @{
        "abilities" = "[" +( $coldata.outcome -join("], [")) + "]"
        "modifiers" = "[" +($coldata.modifier -join("], [")) + "]"
        "PointCosts" =  "[" +($coldata.pointcost -join("], [")) + "]"
        "TotalCost" = $cost.sum
        "CostValidate" = (($cost.sum /27))
        "orderedabilities" = "{" +( ($coldata.outcome | sort -Descending) -join(", ")) + "}"
        "orderedmodifiers" = "{" +(($coldata.modifier | sort -Descending) -join(", ")) + "}"
        "RawModSum" = $measuremod.sum
        "RawModMin" = $measuremod.Minimum
        "RawModMax" = $measuremod.Maximum
        "RawModAvg" = $measuremod.Average
        "RawMod2nd" = $coldata.Rawmod | sort | select -Skip 1 | select -First 1
        "RawMod5th" = $coldata.Rawmod | sort -Descending | select -Skip 1 | select -First 1
        "RawModMid" = ($measuremod.Minimum+ $measuremod.Maximum)/2
        "diceRolls" = "[" +($coldata.DiceRolls -join("], [")) + "]"
    }
    return $colitem
}
function verify-abilities {
    do {

        $checkval = show-abilities
    } while (($checkval.rawmodsum -ge 8.5) -or ($checkval.rawmodmid -gt $checkval.rawmodavg) -or ($checkval.rawmodavg -ge 8.5) -or ($checkval.rawmodsum -le 3) -or ($checkval.rawmodmid -lt 1) -or ($checkval.RawMod2nd -lt -0.5) -or ($checkval.RawMod2nd -ge 0.5)-or ($checkval.RawModmin -lt -1.5 ) -or ($checkval.RawMod5th -ge [math]::Truncate($checkval.RawModmax)) -or ($checkval.CostValidate -lt 0.8)-or ($checkval.CostValidate -gt 1.2))
    $checkval 

}

#for ($v=1;$v -lt 100; $v++){
#verify-abilities | select orderedabilities, orderedmodifiers , rawmodmid, rawmodavg | Format-Table -AutoSize  }
#$MergeData = collate-abilities 10
#$MergeData | group rawmodmin | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmin.csv 
#$MergeData | group rawmodmax | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmax.csv
#$MergeData | group rawmodmid | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmid.csv
#| Export-Csv -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmod.csv -NoTypeInformation