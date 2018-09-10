param 
(
    [Parameter(Mandatory=$true)] $VersionNumber
)

.\Utils\Package.ps1 -Action BuildCookArchive -Configuration Shipping -Platform Win64 -VersionNumber $VersionNumber