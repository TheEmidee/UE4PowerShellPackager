$Parameters.ArchiveDirectoryRoot = "D:\Builds"
$Parameters.UERootFolder = "F:\Epic\UE_4.20" 
$Parameters.ProjectDir = "F:\Projects\ProjectName"
$Parameters.ProjectName = "ProjectName"
$Parameters.BackupDirectoryRoot = "F:\Versions"

$Parameters.PlatformRegionMap = @{ 
    PS4=@{ 
        "Europe"="EuropeTitleId";
        "Japan"="JapanTitleId" 
    };
    Switch=@{ 
        "Europe"="EuropeTitleId";
        "Japan"="JapanTitleId" 
    };
}