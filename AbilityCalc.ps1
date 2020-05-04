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
function get-abilities {
$abilities = @()
for ($r=1; $r -le 6; $r++){
$data = (Roll-Die 6 4)
$outcome = (($data | sort result -Descending | select -First 3 ) | measure result -sum).sum
$ability =  New-Object -TypeName PSObject -Property @{
"DiceRolls" = $data.outcomes -join("| ")
"RollCount" = ($data| measure rollcount -sum).sum
"Outcome" =  $outcome
"RawMod" = ($outcome - 10)/2
"Modifier" = [math]::floor((($outcome - 10)/2))
}
$abilities += $ability
}
return $abilities
}
#$ability = $data | sort result -Descending | select -First 3 
function collate-abilities ($itterations = 1000) {
$collation =@()
for ($it=1; $it -lt $itterations; $it++){
$coldata = get-abilities
$measuremod = ($coldata | measure rawmod -Sum -Minimum -Maximum -Average)
$colitem =  New-Object -TypeName PSObject -Property @{
"abilities" = $coldata.outcome -join(", ")
"modifiers" = $coldata.modifier -join(", ")
"RawModSum" = $measuremod.sum
"RawModMin" = $measuremod.Minimum
"RawModMax" = $measuremod.Maximum
"RawModAvg" = $measuremod.Average
"RawModMid" = ($measuremod.Minimum+ $measuremod.Maximum)/2
}
$collation += $colitem
}
return $collation

}

$MergeData = collate-abilities 100000 
$MergeData | group rawmodmin | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmin.csv 
$MergeData | group rawmodmax | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmax.csv
$MergeData | group rawmodmid | select name, count | Export-Csv -NoTypeInformation -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmodmid.csv
#| Export-Csv -Path C:\Users\Hackspace\Documents\GitHub\DnD\abmod.csv -NoTypeInformation