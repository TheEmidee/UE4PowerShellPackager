$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

. ("$ScriptDirectory\HelperFunctions.ps1")
. ("$ScriptDirectory\BuildParameters.ps1")
. ("$ScriptDirectory\Platform.ps1")
. ("$ScriptDirectory\Configuration.ps1")
. ("$ScriptDirectory\Action.ps1")
. ("$ScriptDirectory\Backup.ps1")