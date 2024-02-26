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

    Context 'Sanity Check' {

        It 'Help' {
            .\Use-ClassAccessors.ps1 -? | Out-String -Stream | Should -Contain SYNOPSIS
        }
    }

    Context 'AccessString' {
        
        BeforeAll {
            Class AccessString {
                [String] get_Empty()  { return @() }
                [String] get_String() { return 'String' }
                [String] get_Array()  { return 'One', 'Two' }
                hidden static AccessString() { .\Use-ClassAccessors.ps1 }
            }
            $AccessString = [AccessString]::new()
        }
        
        It 'Empty' {
           $AccessString.Empty | Should -BeNullOrEmpty # See: https://github.com/PowerShell/PowerShell/issues/21250
        }
        
        It 'String' {
            $AccessString.String | Should -BeOfType String
            $AccessString.String | Should -Be String
        }
        
        It 'Array' {
            $AccessString.Array | Should -BeOfType String
            $AccessString.Array | Should -Be 'One Two'
        }
    }
        
    Context 'AccessObject' {
        
        BeforeAll {
            Class AccessObject {
                [Object] get_Empty()  { return @() }
                [Object] get_String() { return 'String' }
                [Object] get_Array()  { return 'One', 'Two' }
                hidden static AccessObject() { .\Use-ClassAccessors.ps1 }
            }
            $AccessObject = [AccessObject]::new()
        }
        
        It 'Empty' {
            $AccessObject.Empty | Should -BeNullOrEmpty
        }
        
        It 'String' {
            $AccessObject.String | Should -BeOfType String
            $AccessObject.String | Should -Be String
        }
        
        It 'Array' {
            $AccessObject.Array | Should -BeOfType Object
            $AccessObject.Array | Should -Be 'One', 'Two'
        }
    }
    
    Context 'AccessStringArray' {
        
        BeforeAll {
            Class AccessStringArray {
                [String[]] get_Empty()  { return @() }
                [String[]] get_String() { return 'String' }
                [String[]] get_Array()  { return 'One', 'Two' }
                hidden static AccessStringArray() { .\Use-ClassAccessors.ps1 }
            }
            $AccessStringArray = [AccessStringArray]::new()
        }
        
        It 'Empty' {
            $AccessStringArray.Empty | Should -BeNullOrEmpty
        }
        
        It 'String' {
            $AccessStringArray.String | Should -BeOfType String
            $AccessStringArray.String | Should -Be String
        }
        
        It 'Array' {
            $AccessStringArray.Array | Should -BeOfType Object
            $AccessStringArray.Array | Should -Be 'One', 'Two'
        }
    }
        
    Context 'AccessArray' {
        
        BeforeAll {
            Class AccessArray {
                [Array] get_Empty()  { return @() }
                [Array] get_String() { return 'String' }
                [Array] get_Array()  { return 'One', 'Two' }
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
}

