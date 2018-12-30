#include "../obj_dir/Valu.h"

#include <stdio.h>

const int datasize = 1024 * 1024;
static unsigned char data[datasize];
const int textsize = 1024 * 1024;
static unsigned char text[textsize];
const int textoffset = 0x100000 << 2;

int main() {
	for (int i = 0; i < datasize; ++i) {
		data[i] = 0;
	}
	for (int i = 0; i < textsize; ++i) {
		text[i] = 0;
	}

	{
		FILE* file = fopen("asm/data.bin", "rb");
		fseek(file, 0, SEEK_END);
		int size = ftell(file);
		fseek(file, 0, SEEK_SET);
		fread(&data[0], size, 1, file);
		fclose(file);
	}

	{
		FILE* file = fopen("asm/text.bin", "rb");
		fseek(file, 0, SEEK_END);
		int size = ftell(file);
		fseek(file, 0, SEEK_SET);
		fread(&text[0], size, 1, file);
		fclose(file);
	}

	Valu top;

	// Reset
	top.rst = 1;
	top.clk = 0;
	top.eval();
	top.clk = 1;
	top.eval();
	top.rst = 0;

	for (int i = 0; i < 5000 && !Verilated::gotFinish(); ++i) {
		top.clk = 1;
		top.eval();
		top.clk = 0;
		top.eval();

		if (top.memop == 1) {
			printf("Preparing address %x.\n", top.memaddress);
			unsigned int* addr = top.memaddress >= textoffset ? (unsigned int*)&text[top.memaddress - textoffset] : (unsigned int*)&data[top.memaddress];
			top.memindata = *addr;
			printf("Loaded %d from address %x.\n", *addr, top.memaddress);
		}
		else if (top.memop == 2) {
			unsigned int* addr = top.memaddress >= textoffset ? (unsigned int*)&text[top.memaddress - textoffset] : (unsigned int*)&data[top.memaddress];
			*addr = top.memoutdata;
		}
	}
	top.final();

	return 0;
}
