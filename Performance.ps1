Class TestClass {
  hidden $_Value
  hidden $_Values = 0..255
  hidden [Byte] get_ByteObject0() {
    return $this._Value
  }
  hidden [Object] get_ObjectByte0() {
    return ,[Byte]$this._Value
  }
  hidden [Byte[]] get_BytesObject() {
    return $this._Values
  }
  hidden [Object] get_ObjectBytes() {
    return ,[Byte[]]$this._Values
  }
  hidden [Object] get_Value() {
    return $this._Value
  }
  hidden set_Value($Value) {
    $this._Value = $Value
  }
}

.\Use-ClassAccessors.ps1 -Force

$Test = [TestClass]::new()

$Test.ByteObject0 | Should -BeOfType Byte

$Test.ObjectByte0 | Should -BeOfType Byte

,$Test.BytesObject | Should -BeOfType Byte[]

,$Test.ObjectBytes | Should -BeOfType Byte[]

$Test.Value = 42
$Test.Value | Should -Be 42

$Repeat = 100
$Results = [Ordered]@{}
(1..100).foreach{
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    $Results.'Direct property read _Value'    += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test._Value } }
    $Results.'Script property read Value'     += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.Value } }
    $Results.'Direct property write _Value'   += Measure-Command { @(1..$Repeat ).foreach{ $Test._Value = $_ } }
    $Results.'Script property write Value'    += Measure-Command { @(1..$Repeat ).foreach{ $Test.Value = $_ } }
    $Results.'Method set_() write Value'      += Measure-Command { @(1..$Repeat ).foreach{ $Test.set_Value($_) } }
    $Results.'Method get_() [Byte][Object]'   += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.get_ByteObject0() } }
    $Results.'Property Get  [Byte][Object]'   += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.ByteObject0 } }
    $Results.'Method get_() [Object][Byte]'   += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.get_ObjectByte0() } }
    $Results.'Property Get  [Object][Byte]'   += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.ObjectByte0 } }
    $Results.'Method get_() [Byte[]][Object]' += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.get_BytesObject() } }
    $Results.'Property Get  [Byte[]][Object]' += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.BytesObject } }
    $Results.'Method get_() [Object][Byte[]]' += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.get_ObjectBytes() } }
    $Results.'Property Get  [Object][Byte[]]' += Measure-Command { @(1..$Repeat ).foreach{ $Void = $Test.ObjectBytes } }
}
$Results