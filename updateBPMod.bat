@echo off

echo Copying Mod.ff to \bpmod folder
xcopy mod.ff ..\bpmod /SY

echo Copying z_bp.iwd to \bpmod folder
xcopy z_bp.iwd ..\bpmod /SY

echo Copying bp_ranks.cfg to \bpmod folder
xcopy bp_ranks.cfg ..\bpmod /SY

echo Copying server.cfg to \bpmod folder
xcopy server.cfg ..\bpmod /SY

echo Copying configs\ to \bpmod\configs folder
xcopy configs ..\bpmod\configs /SY

echo Copying break.cfg to \bpmod folder
xcopy break.cfg ..\bpmod /SY

echo Done.
pause