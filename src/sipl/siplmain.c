

int main(void)
{
    char *vram = (char*) 0xa0000;
    unsigned int ptr;
    for(ptr=0; ptr<0xffff; ptr++)
        vram[ptr] = 0x03;
    for(;;){}
}
