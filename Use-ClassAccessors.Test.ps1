#Requires -Modules @{ModuleName="Pester"; ModuleVersion="5.5.0"}

Describe 'Use-ClassAccessors' {

    BeforeAll {

        Set-StrictMode -Version Latest
        
        Class ExampleClass {
            hidden $_Value
            hidden [Object] get_Value() {
              return $this._Value
            }
            hidden set_Value($Value) {
              $this._Value = $Value
            }
            hidden [Type]get_Type() {
              if ($Null -eq $this.Value) { return $Null }
              else { return $this._Value.GetType() }
            }
            hidden static ExampleClass() { .\Use-ClassAccessors.ps1 }
        }
        $Example = [ExampleClass]::new()
    }

    Context 'Load Check' {

        It 'Help' {
            .\Use-ClassAccessors.ps1 -? | Out-String -Stream | Should -Contain SYNOPSIS
        }
    }

    Context 'Exa,ple' {

        It 'Instance' {
            $Example.Value | Should -BeNullOrEmpty
        }

        It 'Setter' {
            { $Example.Value = 42 } | Should -not -throw
        }

        It 'Getter' {
            $Example.Value | Should -be 42
        }

        It 'ReadOnly Getter' {
            $Example.Type | Should -be int
        }

        It 'Prohibit Write' {
            { $Example.Type = 'Something' } | Should -throw
        }
    }

    Context 'AccessString' {
        
        BeforeAll {
            Class AccessString {
                [String] get_Empty()  { return @() }
                [String] get_String() { return 'String' }
                [String] get_Single() { return @('Single') }
                [String] get_Array()  { return 'One', 'Two' }
                hidden static AccessString() { .\Use-ClassAccessors.ps1 }
            }
            $AccessString = [AccessString]::new()
        }
        
        It 'Empty' {
           Should -ActualValue $AccessString.Empty -BeNullOrEmpty # See: https://github.com/PowerShell/PowerShell/issues/21250
        }
        
        It 'String' {
            Should -ActualValue $AccessString.String -BeOfType String
            Should -ActualValue $AccessString.String -Be String
        }
        
        It 'Single' {
            Should -ActualValue $AccessString.Single -BeOfType String
            Should -ActualValue $AccessString.Single -Be 'Single'
        }
        
        It 'Array' {
            Should -ActualValue $AccessString.Array -BeOfType String
            Should -ActualValue $AccessString.Array -Be 'One Two'
        }
    }
        
    Context 'AccessObject' {
        
        BeforeAll {
            Class AccessObject {
                [Object] get_Empty()  { return @() }
                [Object] get_String() { return 'String' }
                [Object] get_Single() { return @('Single') }
                [Object] get_Array()  { return 'One', 'Two' }
                hidden static AccessObject() { .\Use-ClassAccessors.ps1 }
            }
            $AccessObject = [AccessObject]::new()
        }
        
        It 'Empty' {
            Should -ActualValue $AccessObject.Empty -BeNullOrEmpty
        }
        
        It 'String' {
            Should -ActualValue $AccessObject.String -BeOfType $AccessObject.get_String().GetType().Name
            Should -ActualValue $AccessObject.String -Be       $AccessObject.get_String()
        }
        
        It 'Single' {
            Should -ActualValue $AccessObject.Single -BeOfType String # Expected: $AccessObject.get_Single().GetType().Name [String[]]
            Should -ActualValue $AccessObject.Single -Be       $AccessObject.get_Single()
        }
        
        It 'Array' {
            Should -ActualValue $AccessObject.Array       -BeOfType $AccessObject.get_Array().GetType().Name
            Should -ActualValue $AccessObject.Array.Count -Be       $AccessObject.get_Array().Count
            Should -ActualValue $AccessObject.Array[0]    -Be       $AccessObject.get_Array()[0]
        }
    }
    
    Context 'AccessStringArray' {
        
        BeforeAll {
            Class AccessStringArray {
                [String[]] get_Empty()  { return @() }
                [String[]] get_String() { return 'String' }
                [String[]] get_Single() { return @('Single') }
                [String[]] get_Array()  { return 'One', 'Two' }
                hidden static AccessStringArray() { .\Use-ClassAccessors.ps1 }
            }
            $AccessStringArray = [AccessStringArray]::new()
        }
        
        It 'Empty' {
            $AccessStringArray.Empty | Should -BeNullOrEmpty
        }
        
        It 'String' {
            $AccessStringArray.String | Should -BeOfType String # Expected: $AccessStringArray.get_String().GetType().Name [String[]]
            $AccessStringArray.String | Should -Be       $AccessStringArray.get_String()
        }
        
        It 'Single' {
            $AccessStringArray.Single      | Should -BeOfType String # Expected: $AccessStringArray.get_Single().GetType().Name [String[]]
            $AccessStringArray.Array.Count | Should -Be       $AccessStringArray.get_Array().Count
            $AccessStringArray.Single      | Should -Be       $AccessStringArray.get_Single()
        }
        
        It 'Array' {
            $AccessStringArray.Array       | Should -BeOfType String # Expected: $AccessStringArray.get_Single().GetType().Name [String[]]
            $AccessStringArray.Array.Count | Should -Be  $AccessStringArray.get_Array().Count
            $AccessStringArray.Array[0]    | Should -Be  $AccessStringArray.get_Array()[0]
        }
    }
        
    Context 'AccessArray' {
        
        BeforeAll {
            Class AccessArray {
                [Object[]] get_Empty()  { return @() }
                [Object[]] get_String() { return 'String' }
                [Object[]] get_Array()  { return 'One', 'Two' }
                hidden static AccessArray() { .\Use-ClassAccessors.ps1 }
            }
            $AccessArray = [AccessArray]::new()
        }
        
        It 'Empty' {
            $AccessArray.Empty | Should -BeNullOrEmpty
        }
        
        It 'String' {
            $AccessArray.String | Should -BeOfType String
            $AccessArray.String | Should -Be String
        }
        
        It 'Array' {
            $AccessArray.Array | Should -BeOfType Object
            $AccessArray.Array | Should -Be 'One', 'Two'
        }
    }

    Context 'Empty list' {
        
        BeforeAll {
            Class TestClass {
                hidden $_List
                [Object] get_List() { return $this._List }
                set_List($List) { $this._List = $List }
            }
            $Test = [TestClass]::new()
            $Test.List = [System.Collections.Generic.List[String]]::new()
        }
    }
    
    Context 'Issues' {
        
        it 'Set empty dictionary' {
            $Properties = [System.Collections.Specialized.OrderedDictionary]::new([StringComparer]::Ordinal)
            $Example.Value = $Properties
            $Example.Value | Should -BeOfType 'System.Collections.Specialized.OrderedDictionary'
        }

        it '#5 Static methods/properties should be excluded' {
            Class TestClass {
                hidden static $Static = 3
                hidden $_Value
                hidden TestClass ($Value) {
                    $this.Value = $Value
                }
                static TestClass() {
                    .\Use-ClassAccessors.ps1
                }
                hidden [Object] get_Value() {
                  return $this._Value
                }
                hidden set_Value($Value) {
                  $this._Value = $Value
                }
                hidden [Type]get_Type() {
                  if ($Null -eq $this.Value) { return $Null }
                  else { return $this._Value.GetType() }
                }
            }

            $Test = [TestClass]::new(1)
            $Test.PSObject.Properties.Name.Count | Should -be 2
            $Test.PSObject.Properties.Name | Should -not -contain Static

        }
    }
}

