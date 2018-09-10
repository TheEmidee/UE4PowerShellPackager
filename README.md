Powershell scripts to ( Build / Cook / Package / Archive / Patch ) Unreal Engine Projects

**Usage**

Call `.\Utils\Package.ps1` with the following mandatory arguments (with the authorized values):
-Action : "BuildEditor", "Build", "Cook", "BuildCook", "BuildCookArchive", "Patch"
-Platform : "Win64", "XboxOne", "PS4", "Switch"
-Configuration: "Development", "Debug", "Shipping"

The full list of the accepted parameters can be found in `BuildParameters.ps1`

To avoid passing arguments which do not change accross all package options (like UERootFolder, ArchiveDirectoryRoot or ProjectName), you can edit the file `UserVariables.ps1`, which is included automatically by `Package.ps1`

The script checks the arguments you give to it to make sure everything is correct before calling RunUAT, and will exit prematurely with an error message so you can fix your command line. (For example, you must provide a version number when building a shipping package, or you must define against which release number you want to create a patch) 

Some options worth noting:

-Backup : if set to $true, the packager will use RoboCopy to copy the output located in the archive directory to a backup location of your choice (defined by the argument BackupDirectoryRoot)

-Stub : if set to $true, the packager won't run any action, but will output in the console the processes it should use, with the arguments. This is useful to check if everything is allright

-PlatformRegionMap : it's a dictionary property which allows, for some platforms (mainly for consoles) to specify which regions your game can be packaged to, associated with the titleid argument you must give to RunUAT, which is the real id of your game in the console administrative backend

As a convenience, you will find some scripts which will call `Package.ps1` with predefined options to quickly use the packager.
They are named `BuildCookArchive-XXX.ps1`. You just need to update UserVariables according to your working environment and you are good to go!
Note than you can add a `param` section at the top of those scripts in case you need to pass user defined arguments to the packager (like the version number in `BuildCookArchive-Win64-Shipping.ps1`)
