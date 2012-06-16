@echo off

set _BUILDPACKAGE=%CD%

echo  * Building distribution package for language %_MODLANGX%...

cd OpenWarfare

..\..\7za a -r -tzip OpenWarfare%_MODVERSION%-%_MODBUILD%-%_MODLANGX%.zip * > NUL
move OpenWarfare%_MODVERSION%-%_MODBUILD%-%_MODLANGX%.zip ..\OpenWarfare-Distribution > NUL

cd %_BUILDPACKAGE% > NUL