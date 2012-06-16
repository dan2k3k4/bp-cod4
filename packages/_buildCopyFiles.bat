@echo off

set _BUILDCOPYFILES=%CD%

echo  * Copying mod language-independent files...

copy /Y ..\*.url .\OpenWarfare\%_MODHOME% > NUL
copy /Y ..\*.txt .\OpenWarfare\%_MODHOME% > NUL
copy /Y ..\*.cfg .\OpenWarfare\%_MODHOME% > NUL

copy /Y ..\configs\*.cfg .\OpenWarfare\%_MODHOME%\configs > NUL
copy /Y ..\configs\gameplay\*.cfg .\OpenWarfare\%_MODHOME%\configs\gameplay > NUL
copy /Y ..\configs\gametypes\*.cfg .\OpenWarfare\%_MODHOME%\configs\gametypes > NUL
copy /Y ..\configs\mover\*.cfg .\OpenWarfare\%_MODHOME%\configs\mover > NUL
copy /Y ..\configs\server\*.cfg .\OpenWarfare\%_MODHOME%\configs\server > NUL

copy /Y _extras_readme.txt .\OpenWarfare\Extras\readme.txt > NUL