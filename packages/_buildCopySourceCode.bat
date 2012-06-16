@echo off

set _BUILDCOPYSOURCECODE=%CD%

echo  * Copying full mod source code...

xcopy ..\configs ..\..\..\raw\configs /SYI > NUL
xcopy ..\images ..\..\..\raw\images /SYI > NUL
xcopy ..\fx ..\..\..\raw\fx /SYI > NUL
xcopy ..\maps ..\..\..\raw\maps /SYI > NUL
xcopy ..\materials ..\..\..\raw\materials /SYI > NUL
xcopy ..\mp ..\..\..\raw\mp /SYI > NUL
xcopy ..\rulesets ..\..\..\raw\rulesets /SYI > NUL
xcopy ..\sound ..\..\..\raw\sound /SYI > NUL
xcopy ..\soundaliases ..\..\..\raw\soundaliases /SYI > NUL
xcopy ..\ui_mp ..\..\..\raw\ui_mp /SYI > NUL
xcopy ..\vision ..\..\..\raw\vision /SYI > NUL
xcopy ..\weapons\fixes ..\..\..\raw\weapons\mp /SYI > NUL
xcopy ..\xanim ..\..\..\raw\xanim /SYI > NUL
xcopy ..\xmodel ..\..\..\raw\xmodel /SYI > NUL
xcopy ..\xmodelparts ..\..\..\raw\xmodelparts /SYI > NUL
xcopy ..\xmodelsurfs ..\..\..\raw\xmodelsurfs /SYI > NUL
xcopy ..\openwarfare ..\..\..\raw\openwarfare /SYI > NUL