class Platform
{
    [Boolean] $CanBePatched
    [Boolean] $CanCompressData
    [String] $Name
    
    Platform()
    {
        $this.CanBePatched = $false
        $this.CanCompressData = $true
    }
    
    [void] ValidateParameters( [BuildParameters] $Parameters )
    {
    }

    [String] GetPackagedFolderName()
    {
        return $this.Name
    }

    [String] GetConfigFolderName()
    {
        return $this.Name
    }

    [String] GetConfigPlatformPath( [BuildParameters] $Parameters )
    {
        return [io.path]::combine( $Parameters.GetConfigPath(), $this.GetConfigFolderName() )
    }

    [void] PreExecute( [BuildParameters] $Parameters )
    {
    }

    [void] PostExecute( [BuildParameters] $Parameters )
    {
    }
}

class PlatformWin64 : Platform
{
    PlatformWin64()
    {
        $this.Name = "Win64"
    }

    [String] GetPackagedFolderName()
    {
        return "WindowsNoEditor"
    }

    [String] GetConfigFolderName()
    {
        return "Windows"
    }
}

class PlatformXboxOne : Platform
{
    PlatformXboxOne()
    {
        $this.Name = "XboxOne"
    }
}

class PlatformSwitch : Platform
{
    PlatformSwitch()
    {
        $this.CanBePatched = $true
        $this.Name = "Switch"
    }
}

class PlatformPS4 : Platform
{
    PlatformPS4()
    {
        $this.CanBePatched = $true
        $this.CanCompressData = $false
        $this.Name = "PS4"
    }

    [String] GetSceFolderPath( [BuildParameters] $Parameters )
    {
        return [io.path]::combine( $Parameters.ProjectDir, "Build", "PS4", "sce_sys" )
    }

    [void] PreExecute( [BuildParameters] $Parameters )
    {
        $config_dir = $this.GetConfigPlatformPath( $Parameters )
        $title_id_config_dir = [io.path]::combine( $config_dir, $Parameters.TitleId )
        $sce_folder_path = $this.GetSceFolderPath( $Parameters )
        $title_id_sce_dir = [io.path]::combine( $sce_folder_path, $Parameters.TitleId )

        Write-Host -ForegroundColor Green "Copy TitleId Files"
        StartProcess "xcopy" "/y $title_id_config_dir\PS4Engine.ini $config_dir"
        StartProcess "xcopy" "/y $title_id_sce_dir\*.* $sce_folder_path"
    }

    [void] PostExecute( [BuildParameters] $Parameters )
    {
        $config_dir = $this.GetConfigPlatformPath( $Parameters )
        $default_title_id_config_dir = [io.path]::combine( $config_dir, $Parameters.DefaultTitleId )
        $sce_folder_path = $this.GetSceFolderPath( $Parameters )
        $default_title_id_sce_dir = [io.path]::combine( $sce_folder_path, $Parameters.TitleId )

        Write-Host -ForegroundColor Green "Restore Default TitleId Files"
        StartProcess "xcopy" "/y $default_title_id_config_dir\PS4Engine.ini $config_dir"
        StartProcess "xcopy" "/y $default_title_id_sce_dir\*.* $sce_folder_path"
    }
}

class PlatformFactory
{
    [Platform] MakePlatform( [String] $name )
    {
        return (New-Object -TypeName "Platform$name")
    }
}

$PlatformFactory = [PlatformFactory]::new()