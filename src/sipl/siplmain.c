typedef unsigned char byte_t;
typedef unsigned short word_t;
typedef unsigned int dword_t;

struct VideoInfo
{
    word_t vmode;
    unsigned short scrnx, scrny;
    void *vram;
}__attribute__((packed));

struct _ColorStruct
{
    byte_t reserve, red, green, blue;
}__attribute__((packed));

union _Color
{
    dword_t value;
    struct _ColorStruct structure;
};
typedef union _Color Color;


void boxfill(struct VideoInfo* vinfo, unsigned short x, unsigned short y, dword_t color);


int main(void)
{
    struct VideoInfo* vinfo = (struct VideoInfo*)0x1f000;
    Color *vram = vinfo->vram;
    unsigned int pixels = vinfo->scrnx * vinfo->scrny;
    unsigned int ptr;
    if(vinfo->vmode!=32)
    {
        vram[0].value = 0x00ff00000;
        for(;;){}
    }
    for(ptr=0; ptr<pixels; ptr++)
    {
        //vram[ptr].value = 0xffff0000;
        vram[ptr].structure.red = 0xff;
        vram[ptr].structure.green = 0xff;
        vram[ptr].structure.blue = 0xff;
    }
    for(;;){}
}


