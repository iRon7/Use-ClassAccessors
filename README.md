<!-- markdownlint-disable MD033 -->
# Use-ClassAccessors

Implements class getter and setter accessors.

## Syntax

```JavaScript
    [-ClassName <String[]>]
    [-PropertyName <String>]
    [-Script <Object>]
    [-Force]
    [<CommonParameters>]
```

## Description

Updates script property of a class from the getter and setter methods.

The conserned methods should be in the following format:

### getter syntax

```PowerShell
[<type>] get_<property name>() {
  return <value>
}
```

### setter syntax

```PowerShell
set_<property name>(<value>) {
  <code>
}
```

## Examples

### Example 1: Class with accessors

The following example define getter and setter for a `value` property
And a _readonly_ property for the type of the type of the contained value.

```PowerShell
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
```

## Parameter

### <a id="-classname">**`-ClassName <String[]>`**</a>

Specifies the name of the class that contain the accessors.
Default: All class in the (current) script (see also: [Script](#script) parameter)

<table>
<tr><td>Type:</td><td></td></tr>
<tr><td>Mandatory:</td><td>False</td></tr>
<tr><td>Position:</td><td>Named</td></tr>
<tr><td>Default value:</td><td></td></tr>
<tr><td>Accept pipeline input:</td><td></td></tr>
<tr><td>Accept wildcard characters:</td><td>False</td></tr>
</table>

### <a id="-propertyname">**`-PropertyName <String>`**</a>

Specifies the property name to update with the accessors.
Default: All properties in the given class or classes (see also: [ClassName](#classname) parameter)

<table>
<tr><td>Type:</td><td></td></tr>
<tr><td>Mandatory:</td><td>False</td></tr>
<tr><td>Position:</td><td>Named</td></tr>
<tr><td>Default value:</td><td></td></tr>
<tr><td>Accept pipeline input:</td><td></td></tr>
<tr><td>Accept wildcard characters:</td><td>False</td></tr>
</table>

### <a id="-script">**`-Script <Object>`**</a>

Specifies the script (block or path) that contains the class source.
Default: the script where this command is invoked

<table>
<tr><td>Type:</td><td></td></tr>
<tr><td>Mandatory:</td><td>False</td></tr>
<tr><td>Position:</td><td>Named</td></tr>
<tr><td>Default value:</td><td></td></tr>
<tr><td>Accept pipeline input:</td><td></td></tr>
<tr><td>Accept wildcard characters:</td><td>False</td></tr>
</table>

### <a id="-force">**`-Force`**</a>

<table>
<tr><td>Type:</td><td></td></tr>
<tr><td>Mandatory:</td><td>False</td></tr>
<tr><td>Position:</td><td>Named</td></tr>
<tr><td>Default value:</td><td></td></tr>
<tr><td>Accept pipeline input:</td><td></td></tr>
<tr><td>Accept wildcard characters:</td><td>False</td></tr>
</table>

