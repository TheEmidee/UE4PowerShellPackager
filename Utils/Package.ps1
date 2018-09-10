param 
(
    [String] $Action,
    [String] $Configuration,
    [String] $Platform,
    [String] $UERootFolder,
    [String] $ProjectDir,
    [String] $ProjectName,
    [String] $ArchiveDirectoryRoot,
    [String] $Region,
    [bool] $BackupVersion=$true,
    [String] $BackupDirectoryRoot,
    [String] $VersionNumber,
    [String] $PatchBaseVersionNumber,
    [bool] $DeployOnDevice=$false,
    [bool] $Stub=$false,
    [bool] $CompileAutomationScripts=$true,
    [bool] $CompileGameEditor=$true
)

$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. ("$ScriptDirectory\Includes.ps1")

Clear-Host

$Parameters = New-Object -TypeName "BuildParameters"
$Parameters.UERootFolder = $UERootFolder
$Parameters.ProjectDir = $ProjectDir
$Parameters.ProjectName = $ProjectName
$Parameters.ArchiveDirectoryRoot = $ArchiveDirectoryRoot
$Parameters.Action = $Action
$Parameters.Configuration = $Configuration
$Parameters.Platform = $Platform
$Parameters.VersionNumber = $VersionNumber
$Parameters.Region = $Region
$Parameters.PatchBaseVersionNumber = $PatchBaseVersionNumber
$Parameters.DeployOnDevice = $DeployOnDevice
$Parameters.CompileAutomationScripts = $CompileAutomationScripts
$Parameters.CompileGameEditor = $CompileGameEditor
$Parameters.BackupDirectoryRoot = $BackupDirectoryRoot
$Parameters.BackupVersion = $BackupVersion
$Parameters.Stub = $Stub

$user_variables_path = "./UserVariables.ps1"

if ( Test-Path $user_variables_path )
{
    . $user_variables_path
}

$global:STUB = $Parameters.Stub 

if ( $Parameters.Stub -eq $true )
{
    Write-Host -ForegroundColor Yellow "*****************"
    Write-Host -ForegroundColor Yellow "*** STUB MODE ***"
    Write-Host -ForegroundColor Yellow "*****************"
    Write-Host -ForegroundColor Yellow ""
}

$Parameters.ValidateParameters()

$PlatformClass = $PlatformFactory.MakePlatform( $Parameters.Platform )
$PlatformClass.ValidateParameters( $Parameters )

$ConfigurationClass = $ConfigurationFactory.MakeConfiguration( $Parameters.Configuration )
$ConfigurationClass.ValidateParameters( $Parameters )

$ActionClass = $ActionsFactory.MakeAction( $Parameters.Action, $PlatformClass, $ConfigurationClass, $Parameters )
$ActionClass.ValidateParameters()

$Backup = [ Backup ]::new( $Parameters, $PlatformClass )
$Backup.ValidateParameters();

Write-Host -ForegroundColor Blue "Platform PreExecute"
Write-Host
$PlatformClass.PreExecute( $Parameters )

try 
{
    Write-Host -ForegroundColor Blue "Execute action : $( $Parameters.Action )"
    Write-Host
    $ActionClass.Execute()

    if ( $Parameters.BackupVersion )
    {
        $Backup.BackupVersion()
    }
}
catch 
{
}

Write-Host -ForegroundColor Blue "Platform PostExecute"
Write-Host
$PlatformClass.PostExecute( $Parameters )