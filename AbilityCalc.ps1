$d6set = @{}
function Roll-Die ([int] $Die, [int] $plural = 1) {
    $dset = @()
    for ($i = 1; $i -le $plural; $i++){
        $rolls = @()
        $tries = 0
        do {
            $dice = Get-Random -Minimum 1 -Maximum ($Die+1)
            $rolls += $dice
        } while (($dice -le 2) -and ($rolls.count -lt 3) )
         $roll = New-Object -TypeName PSObject -Property @{
         'Outcomes' = $rolls -join( ", ")
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
$abilities = @()
for ($r=1; $r -le 1000; $r++){
$data = (Roll-Die 6 4)
$ability =  New-Object -TypeName PSObject -Property @{
"DiceRolls" = $data.outcomes -join("| ")
"RollCount" = ($data| measure rollcount -sum).sum
"outcome" =  (($data | sort result -Descending | select -First 3 ) | measure result -sum).sum
}
$abilities += $ability
}
#$ability = $data | sort result -Descending | select -First 3 
$abilities