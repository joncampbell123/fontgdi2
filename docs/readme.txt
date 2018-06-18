
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
This includes Windows 3.1, Windows 95, and Windows 98. Whether or not it works
under Windows Millenium is a mystery to me because I haven't tested FONTGDI
under those conditions yet. FONTGDI will *NOT* work under Windows NT/2000!
    The only area that Windows has trouble now seems to be when it is displaying
the infamous "blue screen of death", where the text appears garbled for some
reason.

How does FONTGDI work?
    FONTGDI works by utilizing a feature that is common on any VGA-compatible
display adaptor, which is the ability to change the character definitions on
the screen (meaning the bytes on the adaptor RAM that describe, for example,
what the letter A looks like). FONTGDI does NOT use the BIOS to do this, rather
it works by intercepting the BIOS and monitoring any video mode changes. If it
detects a mode change, it lets the BIOS do the work and then changes the
character definitions by directly communicating with the adaptor.

Will FONTGDI work with my video adaptor?
    Probably. I can't guarantee it. There are many variations and inherent
"bugs" related to the ability to change character definions for text mode
and they may cause undesirable effects when FONTGDI is at work. In v2.1,
for example, I modified FONTGDI to correct for a bug in my S3 Virge DX
PCI (not to mention innumerable other SVGA chipsets that had this) that caused
only every other scan line of the charcter to be changed, resulting in an
unreadable hash when a new font was loaded. The revision caused FONTGDI to
work on my laptop as well, which means I probably fixed a major snafu related
to performing such an action.
    If you are running FONTGDI on a Compaq, I can ASSURE you it won't work.
Compaq computers are one of the most incompatible computer systems around. Also,
FONTGDI will not be able to work it's magic under Windows NT/2000 because of
the standard Windows NT paranoia regarding hardware access.

Where can I get utilities to develop my own fonts?
    I have not developed them yet. Currently, the only way to make a font file
is to use an assembly language 'template' that contains no code, just a bunch
of DB statements and the data written out in binary (i.e., 00000000b), then
to assemble as a COM file and rename to FNT.

Where can I get that ASM template?
    WHAT!?!?! You seriously want to do THAT!?!?! Trust me, that is NO way to
write your own font. Just be patient, and I'll get around to developing some.
If you're the impatient type, I suggest writing your own font editor because
the FNT file structure FONTGDI uses is not really that complicated. It is
documented in the DOCS directory.

Can I use FONTGDI fonts with Windows? I see files in WINDOWS\FONTS with the
same extension...
    No. Windows uses a more complex FNT file format that is quite different
from what FONTGDI recognizes.

Can I write a DOS program that communicates with FONTGDI?
    Yes. FONTGDI exports an API that a program can use via INT 68h. This API
is documented in the DOCS directory. All "obsolete" functions are included.

Where can I get previous versions of FONTGDI?
    Trust me.... you don't. Earlier versions had many incompatibilites and
problems (many mentioned eariler in this README) and exported a sort of
System API that didn't really work well. The underlining code was pointless,
the italicing routines made the text unreadable no matter how I prettied it
up, and they had problems of making unreadable hash out of your screen. Part
of it relates to my inexperience with assembly language at the time when I
was writing FONTGDI. When I was cleaning up the code for this revision I
was sort of humored by my earlier inexperience and insecurity writing my code
to pointlessly push and pop things off the stack, for example.

Why is it when I run most text-based DOS games all the text doesn't fill the
screen, it fills the upper half and leaves the lower half blank or as-is?
    Most DOS games and programs tend to assume that when they call BIOS for
standard text mode, they get 80 column by 25 rows color text which is a fine
programming assuption for most cases. However, since FONTGDI changes the amount
of rows in standard text mode, this assuption fails because the first 25 rows
no longer fill the screen.
    Some programs, however, are very astute about determining how many rows of
video are visible, and can adjust themselves to fill it whatever it might be.
Programs like this include Windows and most text editors.

