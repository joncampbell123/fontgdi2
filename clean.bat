@echo off
if exist *.obj del *.obj /q
if exist *.map del *.map /q
if exist *.mix del *.mix /q
if exist util\*.mix del util\*.mix /q
if exist *.msg del *.msg /q
if exist *.err del *.err /q
if not "%1" == "EXECLEAN" goto end

if exist fontgdi.exe del fontgdi.exe /q
if exist util\capvset.exe del util\capvset.exe /q
if exist util\loadfnt.exe del util\loadfnt.exe /q

:end
