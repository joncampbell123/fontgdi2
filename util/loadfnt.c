#include <dos.h>
#include <stdio.h>
#include <graphics.h>

char cline[512];

LoadCLine(int argc,char *argv[])
{
    int n;

    cline[0] = 0;
    for (n=0;n < argc;n++) {
        strcat(cline,argv[n+1]);
        strcat(cline," ");
    }
}

void PrintHelp()
{
	printf("USAGE: [font file] [options]\n");
	printf("\n");
    printf("/BO[+|-]    Enables/Disables bold text (FONTGDI 1.10+)\n");
    printf("/BCGI[+|-]  Enables/Disables BIOS CGI interception (FONTGDI 1.79+)\n");
	printf("/D[+|-]     Enables/Disables automatic text change\n");
	printf("/I[+|-]     Enables/Disables italic text (FONTGDI 1.10+)\n");
	printf("/IS[0..9]   Sets italics shift byte value (FONTGDI 1.75+)\n");
    printf("/IU[+|-]    Enables/Disables inverted underlines (FONTGDI 1.31+)\n");
	printf("/MD[+|-]    Enables/Disables FONTGDI\n");
    printf("/SHF[0..1]  Selects italics shifting mode (FONTGDI 1.80+)\n");
    printf("/U[+|-]     Enables/Disables underlined text (FONTGDI 1.20+)\n");
	exit(0);
}

main(int argc,char *argv[])
{
    FILE *f;
    char fontmap[32*256];
    char datalod[32*256];
    char *ptr2;
    char c;
    unsigned p,cc;
    int chars;
    char pts,dpts,ccc;
    char far *r;
    double ver;
    char stylebits;
    char need_up;
    int xx,yy;

    LoadCLine(argc,argv);

    if ((ptr2 = stristr(cline,"/HELP")) != NULL) PrintHelp();
	if ((ptr2 = stristr(cline,"/?")) != NULL) PrintHelp();

    need_up=0;

    if (getvect(0x68) == NULL) {
        printf("FONTGDI not loaded in memory.\n");
        exit(0);
    }
    _AH = 0x00;
    geninterrupt(0x68);
    if (_BX != 0x1234) {
        printf("FONTGDI not loaded in memory.\n");
        exit(0);
    }
    ver = 0;
    ver += _CH;
    ver /= 10; ver += _CL;
    ver /= 10; ver += _AL;
    ver /= 10; ver += _AH;
    printf("FONTGDI loaded. version %.3f.\n",ver);
    if (argv[1] == NULL) {
    }
    else if (isxdigit(argv[1][0]) || isalpha(argv[1][0])) {
        f=fopen(argv[1],"rb");
        if (f) {
            fread(datalod,4,1,f);
            datalod[4] = 0;
            if (strcmpi(datalod,"FONT") == 0) {
                fread(&pts,1,1,f);
                fread(&dpts,1,1,f);
                fread(&chars,2,1,f);
                r = (char far *) &fontmap[0];
                _AH = 0x02;
                _SI = FP_OFF(r);
                _DS = FP_SEG(r);
                geninterrupt(0x68);
                fread(datalod,chars*pts,1,f);
                for (p=0;p < chars;p++) {
                    for (cc=0;cc < 32;cc++) {
                        if (cc < pts) fontmap[(p*32)+cc] = datalod[(p*pts)+cc];
                        else          fontmap[(p*32)+cc] = 0;
                    }
                }
                _AH = 0x01;
                if (dpts > 0 && dpts < 32) _AL = dpts;
                else                       _AL = pts;
                _SI = FP_OFF(r);
                _DS = FP_SEG(r);
                geninterrupt(0x68);
            }
            else {
                printf("%s is not a valid FONTGDI FNT file\n",argv[1]);
            }
        }
        else {
            printf("Could not open file %s\n",argv[1]);
        }
    }

    _AL = 0;
    _AH = 0x13;
    geninterrupt(0x68);
    stylebits = _AL;
    if (ver >= 1.9) {
        _AH = 4;
        geninterrupt(0x68);
        printf("Have %u86 CPU.\n",_AL);
    }
    if (ver >= 1.95) {
        _AH = 0x12;
        geninterrupt(0x68);
        if (_AL & 0x40) {
            printf("INT 68H AH = 16H supported.\n");
            _AH = 0x16;
            geninterrupt(0x68);
            if (!(_AL & 0x01)) {
                printf("FONTGDI did not detect required CPU.\n");
            }
            if (_AL & 0x02) {
                printf("FONTGDI detected protected mode.\n");
            }
            if (_AL & 0x04) {
                printf("FONTGDI detected Virtual 8086 mode.\n");
            }
        }
        if (_AL & 0x80) printf("FONTGDI now supports system functions.\n");
    }
    if (ver >= 1.971) {
        _AH = 0x12;
        geninterrupt(0x68);
        if (_AL & 0x20) printf("INT 10H AH = 0Eh hooked.\n");
        if (_AL & 0x10) printf("INT 16H hooked.\n");
        if (_AL & 0x08) printf("INT 15H AH = 4Fh hooked.\n");
    }
    if (ver >= 1.1) {                                               /* any font styles? (version 1.10+) */
        if ((ptr2 = stristr(cline,"/BO")) != NULL) {                 /* user select bold? */
            ptr2 += 3;
            ccc = ptr2[0];
            if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x20);
            else                          stylebits |= 0x20;
            need_up=1;
        }
        if ((ptr2 = stristr(cline,"/I")) != NULL) {                 /* user select italic? */
            if (ver < 1.85) {
                ptr2 += 2;
                ccc = ptr2[0];
                if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x40);
                else                          stylebits |= 0x40;
            }
            else {
                printf("This function (/I) has been obselete since FONTGDI version 1.85.\n");
            }
        }
        if ((ptr2 = stristr(cline,"/U")) != NULL) {                 /* user select underline? (version 1.20+) */
            if (ver >= 2.0) {
                printf("This function (/U) has been obselete since FONTGDI version 2.0.\n");
            }
            else if (ver >= 1.2) {
                ptr2 += 2;
                ccc = ptr2[0];
                if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x80);
                else                          stylebits |= 0x80;
            }
            else {
                printf("\n");
                printf("Unsupported switch: /U. For this switch to work, you must load\n");
                printf("FONTGDI version 1.20 or higher.\n");
            }
        }
        if ((ptr2 = stristr(cline,"/IU")) != NULL) {                 /* user select inverted underline? (version 1.31+) */
            if (ver >= 2.0) {
                printf("This function (/IU) has been obselete since FONTGDI version 2.0.\n");
            }
            else if (ver >= 1.31) {
                ptr2 += 3;
                ccc = ptr2[0];
                if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x10);
                else                          stylebits |= 0x10;
            }
            else {
                printf("\n");
                printf("Unsupported switch: /IU. For this switch to work, you must load\n");
                printf("FONTGDI version 1.31 or higher.\n");
            }
        }
    }
    if ((ptr2 = stristr(cline,"/D")) != NULL) {                 /* user select disable? */
        ptr2 += 2;
        ccc = ptr2[0];
        if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x02);
        else                          stylebits |= 0x02;
    }
    if ((ptr2 = stristr(cline,"/MD")) != NULL) {                 /* user select master disable? */
        ptr2 += 3;
        ccc = ptr2[0];
        if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x01);
        else                          stylebits |= 0x01;
    }
    if ((ptr2 = stristr(cline,"/IS")) != NULL) {                 /* user select set italic shift byte (version 1.75+) ? */
        ptr2 += 3;
        if (ver >= 2.0) {
            printf("This function (/IS) has been obselete since FONTGDI version 2.0.\n");
        }
        else if (ver >= 1.75) {
            if (ver < 1.85) {
                cc = ptr2[0];
                if (cc >= '0' && cc <= '9') {
                    ccc = (cc-'0');
                    _AH = 0x14;
                    _AL = 0x80;
                    _CL = ccc;
                    geninterrupt(0x68);
                }
                else {
                    printf("\nUSAGE OF /IS switch: /ISn\n");
                    printf("\nWhere n is a number from 0 to 9\n");
                }
            }
            else {
                printf("This function (/IS) has been obselete since FONTGDI version 1.85.\n");
            }
        }
        else {
            printf("\n");
            printf("Unsupported switch: /IS. For this switch to work, you must load\n");
            printf("FONTGDI version 1.75 or higher.\n");
        }
    }
    if ((ptr2 = stristr(cline,"/BCGI")) != NULL) {
        if (ver >= 2.0) {
            printf("This switch is obselete for FONTGDI 2.0 or higher.\n");
        }
        else if (ver >= 1.79) {
            ptr2 += 5;
            ccc = ptr2[0];
            if (ccc == '-' || ccc == '0') stylebits &= (0xFF^0x04);
            else                          stylebits |= 0x04;
        }
        else {
            printf("\n");
            printf("Unsupported switch: /BCGIB. For this switch to work, you must load\n");
            printf("FONTGDI version 1.79 or higher.\n");
        }
    }
    _AL = 0x80;
    _AH = 0x13;
    _CL = stylebits;
    geninterrupt(0x68);
    if (ver >= 1.972 && ver < 2.0) {
        _AL = 0x00;
        _AH = 0x22;
        geninterrupt(0x68);
        if (_AL == 0x00) {
            printf("Time is %02u:%02u:%02u  date is %u-%u-%u.\n",_CL,_BH,_BL,_DH,_DL,_SI);
            _AL = 0x02;
            _AH = 0x22;
            geninterrupt(0x68);
            if (ver >= 1.973) {
                if (_AL == 0xF0) {
                    printf("Unable to get Alarm time.\n");
                }
                if (_AL == 0x00) {
                    printf("Alarm time is %02u:%02u:%02u.\n",_CL,_BH,_BL);
                }
            }
            if (ver >= 1.974) {
                _AL = 0x04;
                _AH = 0x22;
                geninterrupt(0x68);
                if (_AL == 0x00) {
                    if (_BX & 1) printf("RTC update was in progress.\n");
                    if (_BX & 2) printf("Daylights saving in effect.\n");
                    if (_BX & 4) printf("Alarm on.\n");
                }
            }
        }
        else if (_AL == 0x10) {
            printf("RTC battery dead.\n");
        }
        else if (_AL == 0x20) {
            printf("RTC disabled.\n");
        }
    }

    if (need_up && ver >= 2.0) {
        _AL = 0x14;
        geninterrupt(0x68);
    }

    if (need_up) {
        xx = curscol();
        yy = cursrow();
        _AL = getvmode() | 0x80;
        _AH = 0;
        geninterrupt(0x10);
        poscurs(yy,xx);
    }
}
