Add-Type -AssemblyName System.Windows.Forms

# Import the rules engine
. $psScriptRoot\Add-CodeGenerationRule.ps1
# Import the individual rules
. $psScriptRoot\WinformsCodeGenerationRules.ps1

# Import the worker commands
. $psScriptRoot\ConvertFrom-TypeToScriptCmdlet.ps1
. $psScriptRoot\ConvertTo-ParameterMetaData.ps1

. $psScriptRoot\Set-Property.ps1
. $psScriptRoot\Add-EventHandler.ps1

$Scripts = Get-ChildItem $psScriptRoot\GeneratedControls `
    -ErrorAction SilentlyContinue -Filter *.ps1
        
$Assemblies = @(
    [Reflection.Assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[Reflection.Assembly]::Load('System.Design, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
)


if (-not $Scripts) {
    # Create the controls directory
    $null = New-Item -Path $psScriptRoot\GeneratedControls -Type Directory `
        -ErrorAction SilentlyContinue

    foreach ($Assembly in $Assemblies) {
        if (-not $Assembly) { continue } 
        $Name = $assembly.GetName().Name
        Write-Progress "Creating Commands" $Name 
        $Results = $Assembly.GetTypes() | 
            Where-Object {
                $_.IsPublic -and
                (-not $_.IsGenericType) -and 
                ($_.FullName -notlike "*Internal*")
            } |
            ConvertFrom-TypeToScriptCmdlet -ErrorAction SilentlyContinue
        $path = "$psScriptRoot\GeneratedControls\$Name.ps1"
        [IO.File]::WriteAllText($Path, $Results)
    }
    
    $Scripts = Get-ChildItem $psScriptRoot\GeneratedControls `
        -ErrorAction SilentlyContinue -Filter *.ps1
} 

foreach ($s in $scripts) {
    . $s.Fullname 
}
