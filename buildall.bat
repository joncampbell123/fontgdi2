@echo off

if "%1" == "EXECLEAN" SET __H__=THOROUGH CLEAN
if "%1" == "CLEAN" SET __H__=CLEAN
if "%1" == "GO" SET __H__=BUILD

if "%1" == "EXECLEAN" call clean execlean
if "%1" == "CLEAN" call clean
if "%1" == "GO" call vc16vars go make

set __H__=

