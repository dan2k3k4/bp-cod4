@echo off

set _BUILDFF=%CD%

echo  * Building mod.ff file for language %_MODLANGX%...

if not exist ..\..\..\zone\%_MODLTARGET% mkdir ..\..\..\zone\%_MODLTARGET%
if not exist ..\..\..\zone_source\%_MODLTARGET% xcopy ..\..\..\zone_source\english ..\..\..\zone_source\%_MODLTARGET% /SYI > NUL

xcopy ..\%_MODLANG% ..\..\..\raw\%_MODLTARGET% /SYI > NUL
copy /Y ..\mod.csv ..\..\..\zone_source > NUL
copy /Y ..\mod_ignore.csv ..\..\..\zone_source\%_MODLTARGET%\assetlist > NUL

cd ..\..\..\bin > NUL

linker_pc.exe -language %_MODLTARGET% -compress -cleanup mod >NUL

cd %_BUILDFF% > NUL
copy /Y ..\..\..\zone\%_MODLTARGET%\mod.ff .\OpenWarfare\%_MODHOME% > NUL

echo  * Building mod.ff file with longer smoke for language %_MODLANGX%...

copy /Y ..\mod.csv ..\..\..\zone_source > NUL
@echo. >> ..\..\..\zone_source\mod.csv
@echo fx,props/american_smoke_grenade_mp >> ..\..\..\zone_source\mod.csv

cd ..\..\..\bin > NUL

linker_pc.exe -language %_MODLTARGET% -compress -cleanup mod >NUL

cd %_BUILDFF% > NUL
copy /Y ..\..\..\zone\%_MODLTARGET%\mod.ff ".\OpenWarfare\Extras\Longer Smoke" > NUL