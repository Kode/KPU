#include "../obj_dir/Valu.h"

#include <iostream>
using namespace std;

static unsigned int instructions[256];

int main() {
	FILE* file = fopen("asm/test.bin", "rb");
	fread(instructions, 4 * 2, 1, file);
	fclose(file);

	Valu top;

	// Reset
	top.rst = top.clk = 0;
	top.eval();
	top.rst = 1;

	top.instruction = 0x0;

	for (int i = 0; i < 2 && !Verilated::gotFinish(); ++i) {
		top.instruction = instructions[i];

		top.clk = 1;
		top.eval();
		top.clk = 0;
		top.eval();
	}
	top.final();

	return 0;
}
