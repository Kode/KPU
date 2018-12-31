#include <Kore/pch.h>

#include <Kore/Graphics4/Graphics.h>
#include <Kore/Log.h>
#include <Kore/System.h>

#include "../obj_dir/Valu.h"

#include <stdio.h>

const int datasize = 1024 * 1024;
static unsigned char data[datasize];
const int textsize = 1024 * 1024;
static unsigned char text[textsize];
const int textoffset = 0x100000 << 2;

static Valu top;

static void update() {
	if (Verilated::gotFinish()) {
		Kore::System::stop();
	}

	top.clk = 1;
	top.eval();
	top.clk = 0;
	top.eval();

	if (top.memop == 1) {
		Kore::log(Kore::Info, "Preparing address %x.\n", top.memaddress);
		unsigned int* addr = top.memaddress >= textoffset ? (unsigned int*)&text[top.memaddress - textoffset] : (unsigned int*)&data[top.memaddress];
		top.memindata = *addr;
		Kore::log(Kore::Info, "Loaded %d from address %x.\n", *addr, top.memaddress);
	}
	else if (top.memop == 2) {
		unsigned int* addr = top.memaddress >= textoffset ? (unsigned int*)&text[top.memaddress - textoffset] : (unsigned int*)&data[top.memaddress];
		*addr = top.memoutdata;
	}

	Kore::Graphics4::begin();
	Kore::Graphics4::clear(Kore::Graphics4::ClearColorFlag);
	Kore::Graphics4::end();
	Kore::Graphics4::swapBuffers();
}

int kore(int argc, char** argv) {
	Kore::System::init("KPU", 640, 480);

	for (int i = 0; i < datasize; ++i) {
		data[i] = 0;
	}
	for (int i = 0; i < textsize; ++i) {
		text[i] = 0;
	}

	{
		FILE* file = fopen("data.bin", "rb");
		fseek(file, 0, SEEK_END);
		int size = ftell(file);
		fseek(file, 0, SEEK_SET);
		fread(&data[0], size, 1, file);
		fclose(file);
	}

	{
		FILE* file = fopen("text.bin", "rb");
		fseek(file, 0, SEEK_END);
		int size = ftell(file);
		fseek(file, 0, SEEK_SET);
		fread(&text[0], size, 1, file);
		fclose(file);
	}

	// Reset
	top.rst = 1;
	top.clk = 0;
	top.eval();
	top.clk = 1;
	top.eval();
	top.rst = 0;

	Kore::System::setCallback(update);
	Kore::System::start();

	top.final();

	return 0;
}
