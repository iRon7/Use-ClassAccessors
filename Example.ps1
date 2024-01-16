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
}

.\Use-ClassAccessors.ps1 -Force

$Example = [ExampleClass]::new()

$Example.Value = 42
$Example.Value              # Returns 42
$Example.Type               # Returns [Int] type info
$Example.Type = 'Something' # Throws readonly error