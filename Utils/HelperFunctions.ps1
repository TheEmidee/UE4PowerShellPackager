function WriteErrorAndExit( [String] $message )
{
    Write-Host -ForegroundColor Red $message
    Exit 1
}

function StartProcess( [String] $process_path, [String] $parameters )
{
    if ( $global:STUB -eq $true )
    {
        Write-Host $process_path
        Write-Host $parameters
    }
    else
    {
        $uat_process = Start-Process -FilePath "$process_path" -ArgumentList "$parameters" -NoNewWindow -Wait
        $uat_process.ExitCode
    }

    Write-Host ""
}