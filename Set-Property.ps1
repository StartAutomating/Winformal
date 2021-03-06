function Set-Property
{
    <#
    .Synopsis
        Sets properties on an object or subscribes to events
    .Description
        Set-Property is used by each parameter in the automatically generated
        controls in Winformal.
    .Parameter InputObject
        The object to set properties on
    .Parameter Hashtable
        A Hashtable contains properties to set.
        The key is the name of the property on an object, or "On_" + the name 
        of an event you can subscribe to (i.e. On_Loaded).
        The value can either be a literal value (such as a string), or a script block that produces the value that needs to be set.
    #>
    param(    
    [Parameter(ValueFromPipeline=$true)]    
    $inputObject,
    [Parameter(Position=0)] 
    [Hashtable]$property
    )
       
    process {    
        if ($property) {
            foreach ($p in $property) {
                foreach ($k in $p.Keys) {
                    if (-not $k) { continue }
                    $realKey = $k
                    if ("$k".StartsWith("On_")) {
                        $realKey = "$k".Substring(3)
                    }
                    Write-Debug $k
                    
                    $realItem  = $inputObject.psObject.Members[$realKey ] 
                    if (-not $realItem) {
                        $realItem = $inputObject.psObject.Members | Where-Object { $_.Name -eq $realKey } 
                    }
                    switch ($realItem.MemberType) {
                        Method {
                            $inputObject."$($realItem.Name)".Invoke(@($p[$realKey]))
                        }
                        Property { 
                            $reflectedProperty = $realItem.TypeNameofValue -as [Type]                         
                            if ($reflectedProperty -and $reflectedProperty.GetInterface("IList")) {
                                Write-Debug $realKey
                                $v = $p[$realKey]
                                if ($v -is [ScriptBlock]) { 
                                    try {
                                        $v = & $v
                                    } catch {
                                        Write-Error $_
                                    } 
                                } 
                                foreach ($i in $v) {                                    
                                    $null = $inputObject."$($realItem.Name)".Add($i)                                                                                                        
                                }
                            } else {                                                                                                        
                                if ($realItem.IsSettable) {
                                    if ($debugPreference -eq "continue") {
                                        Write-Debug "Setting $($realItem.Name) to $($p[$realKey] | Out-String)"
                                    }
                                    
                                    $v = $p[$realKey]
                                    if ($v -is [ScriptBlock]) {
                                        $v = & $v
                                    }
                                    $inputObject."$($realItem.Name)" = $v
                                }
                            }                            
                        }
                        Event {
                            $sb = [ScriptBlock]::Create($p[$k])
                            Add-EventHandler $InputObject $RealItem.Name $sb
                        }
                    }
                }
            }
        }
    }
}