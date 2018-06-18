
all: fontgdi.exe util\loadfnt.exe util\capvset.exe

util\capvset.mix: util\capvset.c
    echo compiling util\capvset.c...
    pc util\capvset.c /c >capvset.msg
    if exist c.err ren c.err util\capvset.err

util\capvset.exe: util\capvset.mix
    echo generating UTIL\CAPVSET.EXE...
    pcl util\capvset.mix

util\loadfnt.mix: util\loadfnt.c
    echo compiling util\loadfnt.c...
    pc util\loadfnt.c /c >loadfnt.msg
    if exist c.err ren c.err util\loadfnt.err

util\loadfnt.exe: util\loadfnt.mix
    echo generating UTIL\LOADFNT.EXE...
    pcl util\loadfnt.mix

fontgdi.obj: fontgdi.asm
    echo assembling FONTGDI.ASM...
    masm fontgdi; >fontgdi.err

fontgdi.exe: fontgdi.obj
    echo generating FONTGDI.EXE...
    link fontgdi.obj,fontgdi.exe,fontgdi.map,,,,,,, >link.err

