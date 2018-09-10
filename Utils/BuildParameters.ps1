class BuildParameters
{
    [String] $Action
    [String] $Configuration
    [String] $Platform
    [String] $VersionNumber
    [String] $ArchiveDirectoryRoot
    [String] $UERootFolder
    [String] $ProjectDir
    [String] $ProjectName
    [String] $Region
    [String] $PatchBaseVersionNumber
    [bool] $DeployOnDevice=$false
    [String] $BackupDirectoryRoot
    [bool] $BackupVersion=$false
    [bool] $Stub=$false
    [bool] $CompileAutomationScripts=$true
    [bool] $CompileGameEditor=$true
    [String] $TitleId
    [String] $DefaultTitleId
    $PlatformRegionMap

    [void] CheckValueIsValid( $param_name, $value, [string[]] $valid_values )
    {
        if ( [string]::IsNullOrEmpty( $value ) )
        {
            WriteErrorAndExit ( "The parameter {0} must be set" -f $param_name )
        }

        $is_in_array = $valid_values -contains $value

        if ( !$is_in_array )
        {
            $valid_values_str = $valid_values -join " | "

            $message = ( "The parameter {0} has not a correct value.`nAllowed values : {1}`nCurrent value : {2}" -f $param_name, $valid_values_str, $value )

            WriteErrorAndExit $message
        }
    }

    [void] ValidateParameters()
    {
        $valid_actions = @( "BuildEditor", "Build", "Cook", "BuildCook", "BuildCookArchive", "Patch" )
        $valid_configurations = @( "Development", "Debug", "Shipping" )
        $valid_platforms = @( "Win64", "XboxOne", "PS4", "Switch" )

        $this.CheckValueIsValid( "Action", $this.Action, $valid_actions )
        $this.CheckValueIsValid( "Configuration", $this.Configuration, $valid_configurations )
        $this.CheckValueIsValid( "Platform", $this.Platform, $valid_platforms )

        if ( $this.PlatformRegionMap.ContainsKey( $this.Platform ) )
        {
            Write-Host "Region information provided for this platform"

            $region_map = $this.PlatformRegionMap[ $this.Platform ]

            if ( !$region_map.ContainsKey( $this.Region ) )
            {
                WriteErrorAndExit "Region informations are provided for this platform but can not find the region $( $this.Region )"
            }
            else
            {
                $this.TitleId = $region_map[ $this.Region ]
                $this.DefaultTitleId = ( $region_map.GetEnumerator() | select -first 1 ).Value
                
                Write-Host "Selected TitleId : $( $this.TitleId )"
                Write-Host "Default TitleId : $( $this.DefaultTitleId )"
                Write-Host
            }
        }
        else
        {
            Write-Host "No region information provided for this platform"
        }
    }

    [String] GetArchiveDirectory()
    {
        return [io.path]::combine( $this.ArchiveDirectoryRoot, $this.Configuration, $this.VersionNumber )
    }

    [String] GetProjectPath()
    {
        return Join-Path $this.ProjectDir ( $this.ProjectName + ".uproject" )
    }

    [String] GetConfigPath()
    {
        return [io.path]::combine( $this.ProjectDir, "Config" )
    }

    [String] GetRunUATPath()
    {
        return Join-Path $this.UERootFolder "Engine\Build\BatchFiles\RunUAT.bat"
    }

    [String] GetUnrealBuildToolPath()
    {
        return Join-Path $this.UERootFolder "Engine\Binaries\DotNET\UnrealBuildTool.exe"
    }

    [String] GetProjectConfigPath()
    {
        return [io.path]::combine( $this.ProjectDir, "Config", $this.Platform )
    }

    [String] GetUATParameters()
    {
        [String] $result = "-project=$( $this.GetProjectPath() ) -noP4 -clientconfig=$( $this.Configuration ) -utf8output -platform=$( $this.Platform )"

        if ( $this.CompileAutomationScripts -eq $true )
        {
            $result += " -nocompile"
        }

        if ( $this.CompileGameEditor -eq $false )
        {
            $result += " -nocompileeditor"
        }

        if ( $this.TitleId -ne "" )
        {
            $result += " -titleid=$( $this.TitleId )"
        }

        # Use the following arguments on a build server ???
        # $result += " -installed -ue4exe=UE4Editor-Cmd.exe"

        return $result
    }
}
