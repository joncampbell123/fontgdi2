#include <dos.h>
#include <stdio.h>

main(int argc,char *argv[])
{
    FILE *dst;
    char buf[32*256];
    int x,i;
    char far *ptr = 0xA0000000;

    outport(0x3C4,0x0100);
    outport(0x3C4,0x0402);
    outport(0x3C4,0x0704);
    outport(0x3C4,0x0300);
    outport(0x3CE,0x0204);
    outport(0x3CE,0x0005);
    outport(0x3CE,0x0006);

    dst=fopen("capvset.dat","wb");
    for (x=0;x < 8;x++) {
        for (i=0;i < (32*256);i++) buf[i] = ptr[i];
        fwrite(buf,32*256,1,dst);
        ptr += (32*256);
    }
    fclose(dst);

    outport(0x3CE,0x0006);
    outport(0x3C4,0x0100);
    outport(0x3C4,0x0302);
    outport(0x3C4,0x0304);
    outport(0x3C4,0x0300);
    outport(0x3CE,0x0004);
    outport(0x3CE,0x1005);
    outport(0x3CE,0x0E06);
}
