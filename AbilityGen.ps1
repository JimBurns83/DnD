function read-abilities ($RawScores) {
    $abilities = @()
    for ($r=1; $r -le 6; $r++){
        #$data = (Roll-Die 6 4)
        $outcome = $RawScores[$r-1]
        $ability =  New-Object -TypeName PSObject -Property @{
            #"DiceRolls" = $data.outcomes -join(", ")
            #"RollCount" = ($data| measure rollcount -sum).sum
            "Outcome" =  $outcome
            "RawMod" = ($outcome - 10)/2
            "Modifier" = [math]::Truncate((($outcome - 10)/2))
            "PointCost" = get-PointCost $outcome
        }
        $abilities += $ability
    }
    return $abilities
}
function show-generated ($RawScores) {
  $coldata = read-abilities $RawScores
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
        #"diceRolls" = "[" +($coldata.DiceRolls -join("], [")) + "]"
    }
    return $colitem
}
function verify-generated ($RawScores, $tc = 27) {
$checkval = show-generated $RawScores
if (#($checkval.rawmodsum -ge 8.5) -or 
    ($checkval.rawmodmid -gt $checkval.rawmodavg) -or 
    #($checkval.rawmodavg -ge 8.5) -or 
    #($checkval.rawmodsum -le 3) -or 
    ($checkval.rawmodmid -lt 1) -or 
    ($checkval.RawMod2nd -lt -0.5) -or ($checkval.RawMod2nd -ge 0.5)-or 
    ($checkval.RawMod2nd -le [math]::Truncate($checkval.RawModmin)) -or 
    #($checkval.RawModmin -le -2 ) -or 
    ($checkval.RawMod5th -ge [math]::Truncate($checkval.RawModmax)) -or 
    ##($checkval.CostValidate -lt 0.8)-or ($checkval.CostValidate -gt 1.2)-or 
    ($checkval.TotalCost -gt [math]::Truncate($tc*1.05)) -or ($checkval.TotalCost -lt [math]::Truncate($tc*0.95))
    ){
    #do nothing
     #$checkval 
    }
    else {
    $checkval 
    }
}
$outcomes = @()
for ($i=1;$i -le 6; $i++){
  $outcomes += 1
}
for ($A=6; $A -le 18; $A++){
$outcomes[0] = $A
for ($B=6; $B -le 18; $B++){
$outcomes[1] = $B
for ($C=6; $C -le 18; $C++){
$outcomes[2] = $C
for ($D=6; $D -le 18; $D++){
$outcomes[3] = $D
for ($E=6; $E -le 18; $E++){
$outcomes[4] = $E
for ($F=6; $F -le 18; $F++){
$outcomes[5] = $F

#$outcomes -join(", ")
#read-abilities $outcomes
verify-generated $outcomes 27 | select orderedabilities, orderedmodifiers, costvalidate, totalcost, rawmodsum, rawmodavg | Format-Table -AutoSize | Out-File -Width 4096 -FilePath C:\Users\Hackspace\Desktop\abilities.txt -Append
}
}
}
}
}   
}


