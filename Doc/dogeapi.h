void abscExit(int code);
int abscSignExit(void(*func)());
void abscSleep();

void* amemMalloc(unsigned int size);
int amemFree(void* addr, unsigned int size);
int amemXalloc(void* addr, unsigned int extended_size);
unsigned int amemSysAlloc(unsigned int size);
unsigned int amemSysGet(unsigned int handle, unsigned int index, unsigned int data_type);
unsigned int amemSysSet(unsigned int handle, unsigned int index, unsigned int data_type);
