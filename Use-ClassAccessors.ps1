<#PSScriptInfo
.VERSION 3.4.1
.GUID 19631007-aef4-42ec-9be2-1cc2854222cc
.AUTHOR Ronald Bode (iRon)
.DESCRIPTION Implements class getter and setter accessors.
.COMPANYNAME
.COPYRIGHT
.TAGS Accessors Getter Setter Class get_ set_ TypeData
.LICENSE https://github.com/iRon7/Use-ClassAccessors/LICENSE.txt
.PROJECTURI https://github.com/iRon7/Use-ClassAccessors
.ICON https://raw.githubusercontent.com/iRon7/Use-ClassAccessors/master/Use-ClassAccessors.png
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

<#
    .SYNOPSIS
        Implements class getter and setter accessors.

    .DESCRIPTION
        Updates script property of a class from the getter and setter methods.

        The conserned methods should be in the following format:

        ### getter

            [<type>] get_<property name>() {
              return <value>
            }

        ### setter

            set_<property name>(<value>) {
              <code>
            }

    .EXAMPLE
        # Class with accessors

        The following example define getter and setter for a `value` property
        And a _readonly_ property for the type of the type of the contained value.

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

    .PARAMETER ClassName

        Specifies the name of the class that contain the accessors.
        Default: All class in the (current) script (see also: [Script] parameter)

    .PARAMETER PropertyName

        Specifies the property name to update with the accessors.
        Default: All properties in the given class or classes (see also: [ClassName] parameter)

    .PARAMETER Script

        Specifies the script (block or path) that contains the class source.
        Default: the script where this command is invoked
#>
    
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('InjectionRisk.Create',    '', Justification = 'script blocks are created from class methods')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'false positives')]
[OutputType([System.Void])]
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ClassName,

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$PropertyName,

    [ValidateNotNullOrEmpty()]
    $Script,

    [switch]$Force
)

begin {
    function StopError($Exception, $Id = 'IncorrectArgument', [ErrorCategory]$Group = [ErrorCategory]::SyntaxError, $Object){
        if ($Exception -is [ErrorRecord]) { $Exception = $Exception.Exception }
        elseif ($Exception -isnot [Exception]) { $Exception = [ArgumentException]$Exception }
        $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new($Exception, $Id, $Group, $Object))
    }
}

process {
    $Callers = Get-PSCallStack | Select-Object -Skip 1
    if (-Not $Script) { $Script = $Callers.InvocationInfo.MyCommand.where({ $_.CommandType -eq 'ExternalScript' }, 'first').ScriptBlock }

    if ($Script -is [ScriptBlock]) {
        $Ast = [System.Management.Automation.Language.Parser]::ParseInput($Script, [ref]$Null, [ref]$Null)
    }
    elseif ($Script) {
        $PathInfo = Resolve-Path $Script -ErrorAction SilentlyContinue
        if (-Not $PathInfo) { StopError "Cannot find path '$Script' because it does not exist." }
        $Errors =  $Null
        $Ast = [Parser]::ParseFile($PathInfo.Path, [ref]$Null, [ref]$Errors)
        if ($Errors) { StopError $Errors[0].Message }
    }
    else {
        StopError 'This Cmdlet should be called from within the script that contains the concerned classes or the script parameter should be provided.'
    }

    foreach ($Class in $Ast.EndBlock.Statements.where{ $_.IsClass -and (-not $ClassName -or $_.Name -in $ClassName) }) {
        $PropertyAccessors = @{}
        $Accessors = $Class.Members.where{
            $_ -is [FunctionMemberAst] -and
            $_.IsPublic -and
            -not $_.IsConstructor -and
            -not $_.IsStatic -and
            -Not $PropertyName -or $_.Name -like '?et_$Property$Name'
        }
        foreach ($Accessor in $Accessors) {
            if ($Accessor.Name -like 'get_*') {
                if ($Accessor.Parameters.Count -eq 0) {
                    $MemberName = $Accessor.Name.SubString(4)
                    $Expression = $Accessor.Body.EndBlock.Extent.Text
                    if (-not $PropertyAccessors.Contains($MemberName)) { $PropertyAccessors[$MemberName] = @{} }
                    $PropertyAccessors[$MemberName].Value = [ScriptBlock]::Create($Expression)
                }
                else { Write-Warning "The method '$($Accessor.Name)' is skipped as it is not parameterless." }
            }
            if ($Accessor.Name -like 'set_*') {
                if ($Accessor.Parameters.Count -eq 1) {
                    $MemberName = $Accessor.Name.SubString(4)
                    $Expression = "param($($Accessor.Parameters[0].Extent.Text)) $($Accessor.Body.EndBlock.Extent.Text)"
                    if (-not $PropertyAccessors.Contains($MemberName)) { $PropertyAccessors[$MemberName] = @{} }
                    $PropertyAccessors[$MemberName].SecondValue = [ScriptBlock]::Create($Expression)
                }
                else { Write-Warning "The method '$($Accessor.Name)' is skipped as it does not have a single parameter" }
            }
        }
        foreach ($MemberName in $PropertyAccessors.get_Keys()) {
            $TypeData = $PropertyAccessors[$MemberName]
            $TypeData.TypeName   = $Class.Name
            $TypeData.MemberType = 'ScriptProperty'
            $TypeData.MemberName = $MemberName
            $TypeData.Force      = $Force
            Update-TypeData @TypeData
        }
    }
}
