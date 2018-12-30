#include "../obj_dir/Valu.h"

#include <stdio.h>

const int memsize = 1024 * 1024;
static unsigned char memory[memsize];

int main() {
	for (int i = 0; i < memsize; ++i) {
		memory[i] = 0;
	}

	FILE* file = fopen("asm/test.bin", "rb");
	fread(memory, 4 * 2, 1, file);
	fclose(file);

	Valu top;

	// Reset
	top.rst = 1;
	top.clk = 0;
	top.eval();
	top.clk = 1;
	top.eval();
	top.rst = 0;

	for (int i = 0; i < 10 && !Verilated::gotFinish(); ++i) {
		top.clk = 1;
		top.eval();
		top.clk = 0;
		top.eval();

		if (top.memop == 1) {
			unsigned int* addr = (unsigned int*)&memory[top.memaddress];
			top.memindata = *addr;
			printf("Loaded %d from address %d.\n", *addr, top.memaddress);
		}
		else if (top.memop == 2) {
			unsigned int* addr = (unsigned int*)&memory[top.memaddress];
			*addr = top.memoutdata;
		}
	}
	top.final();

	return 0;
}
