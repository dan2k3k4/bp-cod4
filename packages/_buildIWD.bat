@echo off

set _BUILDIWD=%CD%

echo  * Building z_openwarfare.iwd file with %_MODWEAPONS%...

cd .. > NUL

xcopy %_MODWEAPONS% weapons\mp /SYI > NUL
del z_openwarfare.iwd > NUL
7za a -r -tzip z_openwarfare.iwd images\*.iwi > NUL
7za a -r -tzip z_openwarfare.iwd sound\*.mp3 > NUL
7za a -r -tzip z_openwarfare.iwd weapons\mp\*_mp > NUL
7za a -r -tzip z_openwarfare.iwd rulesets\leagues.gsc > NUL
7za a -r -tzip z_openwarfare.iwd rulesets\openwarfare\*.gsc > NUL
del /f /q weapons\mp\* >NUL
rmdir weapons\mp >NUL

cd %_BUILDIWD% > NUL
copy ..\z_openwarfare.iwd .\.. > NUL