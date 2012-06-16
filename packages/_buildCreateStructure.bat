@echo off

set _BUILDCREATESTRUCTURE=%CD%

echo  * Creating distribution packages folder structure...

mkdir OpenWarfare-Distribution
mkdir OpenWarfare > NUL
mkdir OpenWarfare\%_MODHOME% > NUL

mkdir OpenWarfare\%_MODHOME%\configs > NUL
mkdir OpenWarfare\%_MODHOME%\configs\gameplay > NUL
mkdir OpenWarfare\%_MODHOME%\configs\gametypes > NUL
mkdir OpenWarfare\%_MODHOME%\configs\mover > NUL
mkdir OpenWarfare\%_MODHOME%\configs\server > NUL

mkdir "OpenWarfare\Extras" > NUL
mkdir "OpenWarfare\Extras\All weapons no sway" > NUL
mkdir "OpenWarfare\Extras\Snipers with increased distance" > NUL
mkdir "OpenWarfare\Extras\The Company Hub weapons" > NUL
mkdir "OpenWarfare\Extras\Longer Smoke" > NUL