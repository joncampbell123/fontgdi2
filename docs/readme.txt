
FONTGDI Q and A.

What is FONTGDI?
    FONTGDI is a program designed to take your boring old DOS console and
change the font so it is more interesting.

How do I install FONTGDI?
    Run FONTGDI.EXE from your command line, and it installs itself in memory.
If you want this done automatically, add a reference to it in your AUTOEXEC.BAT
file.

How do I uninstall FONTGDI?
    Don't run FONTGDI.EXE. If FONTGDI.EXE is already in memory, you can flush
it out by restarting your computer. If you ran FONTGDI.EXE within a Windows
DOS-box, you can flush FONTGDI.EXE simply by typing "exit" within the
DOS-box.

Does FONTGDI work with Windows?
    Yes, but the effect of FONTGDI does not show unless you are in a DOS-box
and Windows switches to a full screen console.
    FONTGDI will run in any version of Windows that start up from a DOS prompt.
This includes Windows 3.1, Windows 95, and Windows 98. FONTGDI will *NOT* work
under Windows NT/2000!

How does FONTGDI work?
    FONTGDI hooks BIOS interrupt INT 10h. When a call is made to set the video
mode, it lets the BIOS do it's work, then changes the character font RAM on
the VGA hardware.

Will FONTGDI work with my video adaptor?
    If it's VGA or SVGA, probably.

How do I develop my own fonts?
    There is an assembly language 'template' that can be assembled with MASM
to make a FNT file. Copy and edit the template and assemble to produce your
font.

Can I use FONTGDI fonts with Windows? I see files in WINDOWS\FONTS with the
same extension...
    No. Windows uses a more complex FNT file format that is quite different
from what FONTGDI recognizes.

Can I write a DOS program that communicates with FONTGDI?
    Yes. FONTGDI exports an API that a program can use via INT 68h. This API
is documented in the DOCS directory. All "obsolete" functions are included.

