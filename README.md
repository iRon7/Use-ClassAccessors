<!-- markdownlint-disable MD033 -->
# Use-ClassAccessors

Implements class getter and setter accessors.

## Syntax

```PowerShell
Use-ClassAccessors
    [-ClassName <String[]>]
    [-PropertyName <String>]
    [-Script <Object>]
    [-Force]
    [<CommonParameters>]
```

## Description

The [Use-ClassAccessors][1] cmdlet updates script property of a class from the getter and setter methods.
Which are also known as [accessors or mutator methods][2].

The getter and setter methods should use the following syntax:

### getter syntax

```PowerShell
[<type>] get_<property name>() {
  return <variable>
}
```

or (which performs a little faster):

```PowerShell
[Object] get_<property name>() {
  return ,[<Type>]<variable>
}
```

### setter syntax

```PowerShell
set_<property name>(<variable>) {
  <code>
}
```

> [!NOTE]
> A **setter** accessor requires a **getter** accessor to implement the related property.

> [!NOTE]
> In most cases, you might want to hide the getter and setter methods using the [`hidden` keyword][3]
> on the getter and setter methods.

## Examples

### Example 1: Using class accessors

The following example defines a getter and setter for a `value` property
and a _readonly_ property for the type of the type of the contained value.

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

.\Use-ClassAccessors.ps1 # -Force

$Example = [ExampleClass]::new()

$Example.Value = 42         # Set value to 42
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

Indicates that the cmdlet reloads the specified accessors,
even if the accessors already have been defined for the concerned class.

<table>
<tr><td>Type:</td><td></td></tr>
<tr><td>Mandatory:</td><td>False</td></tr>
<tr><td>Position:</td><td>Named</td></tr>
<tr><td>Default value:</td><td></td></tr>
<tr><td>Accept pipeline input:</td><td></td></tr>
<tr><td>Accept wildcard characters:</td><td>False</td></tr>
</table>

## Related Links

* 1: [Online Help][1]
* 2: [Mutator method][2]
* 3: [Hidden keyword in classes][3]

[1]: https://github.com/iRon7/Use-ClassAccessors "Online Help"
[2]: https://en.wikipedia.org/wiki/Mutator_method "Mutator method"
[3]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_classes#hidden-keyword "Hidden keyword in classes"
