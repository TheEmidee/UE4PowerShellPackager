class Backup
{
    [BuildParameters] $Parameters
    [Platform] $Platform

    Backup( [BuildParameters] $Parameters, [Platform] $Platform )
    {
        $this.Parameters = $Parameters
        $this.Platform = $Platform
    }

    [void] ValidateParameters()
    {
        if ( $this.Parameters.BackupVersion -and [string]::IsNullOrEmpty( $this.Parameters.BackupDirectoryRoot ) )
        {
            WriteErrorAndExit "The parameter BackupDirectoryRoot must be set to backup the version"
        }
    }

    [void] BackupVersion()
	{
        $from = [io.path]::combine( 
            $this.Parameters.GetArchiveDirectory(),
            $this.Platform.GetPackagedFolderName(),
            $this.Parameters.TitleId
        )

        Write-Host -ForegroundColor Blue "Backup version"
        Write-Host "From : $from"

        $to = [io.path]::combine( 
            $this.Parameters.BackupDirectoryRoot, 
            $this.Parameters.ProjectName,
            $this.Parameters.Configuration, 
            $this.Parameters.VersionNumber, 
            $this.Platform.GetPackagedFolderName(),
            $this.Parameters.TitleId
            )
        
        Write-Host "To : $to"

        $robocopy_args = "/E /FFT /R:3 /W:10 /Z /NP /NDL"
        $robocopy_params = "$from $to $robocopy_args"

        Write-Host
        StartProcess "robocopy" $robocopy_params
	}
}