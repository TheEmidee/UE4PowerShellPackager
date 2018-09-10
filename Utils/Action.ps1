class Action
{
    [Platform] $Platform
    [Configuration] $Configuration
    [BuildParameters] $BuildParameters

    Action( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
    {
        $this.Platform = $Platform
        $this.Configuration = $Configuration
        $this.BuildParameters = $BuildParameters
    }

    [String] GetBuildCookRunArguments()
    {
        return ""
    }

    [void] ValidateParameters()
    {
    }

    [void] Execute()
    {
        $additional_parameters = $this.BuildParameters.GetUATParameters()
        $build_cook_parameters = $this.GetBuildCookRunArguments() 

        $parameters = "BuildCookRun $additional_parameters $build_cook_parameters"
        $uat = $this.BuildParameters.GetRunUATPath()

        StartProcess $uat $parameters
    }
}

class ActionBuildEditor : Action
{
    ActionBuildEditor( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }

    [void] Execute()
    {
        $unreal_build_tool = $this.BuildParameters.GetUnrealBuildToolPath()
        $parameters = $this.BuildParameters.ProjectName + "Editor Win64 Development " + $this.BuildParameters.GetProjectPath()
    
        StartProcess $unreal_build_tool $parameters
    }
}

class ActionBuild : Action
{
    ActionBuild( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }

    [String] GetBuildCookRunArguments()
    {
        return "-build -skipcook"
    }
}

class ActionCook : Action
{
    ActionCook( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }

    [String] GetBuildCookRunArguments()
    {
        $config_cook_arguments = $($this.Configuration).CookArguments
        $result = "-compile -allmaps -pak -cook -unversionedcookedcontent -package $config_cook_arguments"

        if ( $this.Platform.CanCompressData -eq $true )
        {
            $result += " -compressed"
        }

        return $result
    }
}

class ActionBuildCook : ActionCook
{
    ActionBuildCook( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }
    
    [String] GetBuildCookRunArguments()
    {
        $base = ( [ActionCook ] $this ).GetBuildCookRunArguments()
        
        return "-build $base"
    }
}

class ActionBuildCookArchive : ActionBuildCook
{
    ActionBuildCookArchive( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }
    
    [String] GetBuildCookRunArguments()
    {
        $base = ( [ActionBuildCook ] $this ).GetBuildCookRunArguments()
        $archive_directory = $this.BuildParameters.GetArchiveDirectory()

        return "$base -stage -archive -archivedirectory=$archive_directory"
    }
}

class ActionPatch : ActionBuildCookArchive
{
    ActionPatch( [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
        : base( $Platform, $Configuration, $BuildParameters )
    {
    }
    
    [String] GetBuildCookRunArguments()
    {
        $base = ( [ActionBuildCookArchive ] $this ).GetBuildCookRunArguments()
        $release_version_root = [io.path]::combine( $this.BuildParameters.ArchiveDirectoryRoot, $this.BuildParameters.Configuration )
        
        return "$base -basedonreleaseversion=$( $( $this.BuildParameters ).PatchBaseVersionNumber ) -basedonreleaseversionroot=$release_version_root -generatepatch"
    }

    [void] ValidateParameters()
    {
        if ( $false -eq $this.Platform.CanBePatched )
        {
            WriteErrorAndExit ( "The selected platform '$( $this.Platform )' does not allow patches" )
        }
        if ( [string]::IsNullOrEmpty( $this.BuildParameters.PatchBaseVersionNumber ) )
        {
            WriteErrorAndExit "You must provide a patch base version number when packaging a patch"
        }
    }
}

class ActionsFactory
{
    [Action] MakeAction( [String] $name, [Platform] $Platform, [Configuration] $Configuration, [BuildParameters] $BuildParameters )
    {
        return ( New-Object -TypeName "Action$name" -ArgumentList $Platform, $Configuration, $BuildParameters )
    }
}

$ActionsFactory = [ActionsFactory]::new()