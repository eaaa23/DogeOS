

int main(void)
{
    char *vram = (char*) 0xa0000;
    unsigned int ptr;
    for(ptr=0; ptr<0xffff; ptr++)
        vram[ptr] = ptr&0x0f;
    for(;;){}
}
