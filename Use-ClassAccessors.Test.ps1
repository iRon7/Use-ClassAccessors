#Requires -Modules @{ModuleName="Pester"; ModuleVersion="5.0.0"}

Class ExampleClass {
    hidden $_Value
    hidden [Object] get_Value() {
      return $this._Value
    }
    hidden set_Value($Value) {
      $this._Value = $Value
    }
    hidden [String]get_Type() {
      if ($Null -eq $this.Value) { return $Null }
      else { return $this._Value.GetType() }
    }
}
.\Use-ClassAccessors.ps1 -Force

Describe 'Use-ClassAccessors' {

    Context 'Sanity Check' {

        It 'Help' {
            .\Use-ClassAccessors.ps1 -? | Out-String -Stream | Should -Contain SYNOPSIS
        }
    }

    Context 'Example' {
        
        BeforeAll {
            $Example = [ExampleClass]::new()
        }

        It 'Set value' {
            { $Example.Value = 42 } | Should -not -Throw
        }

        It 'Get value' {
            $Example.Value | Should -Be 42
        }

        It 'Get type' {
            $Example.Type | Should -BeOfType String
            $Example.Type | Should -Be Int
        }
        
        It 'Set value' {
            { $Example.Type = 'Something' } | Should -Throw "'Type' is a ReadOnly property."
        }
    }
}
