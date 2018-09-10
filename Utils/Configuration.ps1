class Configuration
{
    [String] $CookArguments

    [void] ValidateParameters( [BuildParameters] $Parameters )
	{
	}
}

class ConfigurationDebug : Configuration
{
    ConfigurationDebug()
    {
        $this.CookArguments = " -iterativecooking"
    }
}

class ConfigurationDevelopment : Configuration
{
    ConfigurationDevelopment()
    {
        $this.CookArguments = " -iterativecooking"
    }
}

class ConfigurationShipping  : Configuration
{
    ConfigurationShipping()
    {
        $this.CookArguments = " -distribution"
    }

    [void] ValidateParameters( [BuildParameters] $Parameters )
	{
        if ( $Parameters.Action -ne "BuildCookArchive" )
        {
            Write-Output "Only the BuildCookArchive build type is allowed for the Shipping configuration"
            Exit 1
        }
        if ( [string]::IsNullOrEmpty( $Parameters.VersionNumber ) )
        {
            Write-Output "You must provide a version number when packaging for shipping"
            Exit 1
        }
    }
}

class ConfigurationFactory
{
    [Configuration] MakeConfiguration( [String] $name )
    {
        return (New-Object -TypeName "Configuration$name")
    }
}

$ConfigurationFactory = [ConfigurationFactory]::new()