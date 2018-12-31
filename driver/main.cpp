#include <Kore/pch.h>

#include <Kore/Graphics4/Graphics.h>
#include <Kore/Graphics4/PipelineState.h>
#include <Kore/IO/FileReader.h>
#include <Kore/Log.h>
#include <C/Kore/Log.h>
#include <Kore/System.h>

#include "../obj_dir/Valu.h"

#include <stdio.h>

void kore_printf(const char* format, ...) {
	va_list args;
	va_start(args, format);
	Kore_logArgs(KORE_LOG_LEVEL_INFO, format, args);
	va_end(args);
}

using namespace Kore;

namespace {
	const int width = 640;
	const int height = 480;

	const int datasize = 1024 * 1024;
	u8 data[datasize];
	
	const int textsize = 1024 * 1024;
	u8 text[textsize];
	const int textoffset = 0x100000 << 2;

	const int framebuffersize = 640 * 480 * 4;
	u8* framebuffer = nullptr;
	const int framebufferoffset = 0x100000 << 4;

	Graphics4::Shader* vertexShader;
	Graphics4::Shader* fragmentShader;
	Graphics4::PipelineState* pipeline;
	Graphics4::TextureUnit tex;
	Graphics4::VertexBuffer* vb;
	Graphics4::IndexBuffer* ib;

	Graphics4::Texture* texture;

	const int clocksPerFrame = 1000;

	Valu top;

	u32* realAddress(IData address) {
		if (address >= framebufferoffset) {
			return (u32*)&framebuffer[address - framebufferoffset];
		}
		if (address >= textoffset) {
			return (u32*)&text[address - textoffset];
		}
		return (u32*)&data[address];
	}

	void update() {
		if (Verilated::gotFinish()) {
			Kore::System::stop();
		}

		Kore::Graphics4::begin();

		framebuffer = texture->lock();

		for (int i = 0; i < clocksPerFrame && !Verilated::gotFinish(); ++i) {
			top.clk = 1;
			top.eval();
			top.clk = 0;
			top.eval();

			if (top.memop == 1) {
				Kore::log(Kore::Info, "Preparing address %x.\n", top.memaddress);
				top.memindata = *realAddress(top.memaddress);
				Kore::log(Kore::Info, "Loaded %d from address %x.\n", *realAddress(top.memaddress), top.memaddress);
			}
			else if (top.memop == 2) {
				*realAddress(top.memaddress) = top.memoutdata;
			}
		}

		texture->unlock();

		Graphics4::clear(Graphics4::ClearColorFlag, 0xff000000);

		Graphics4::setPipeline(pipeline);
		Graphics4::setTexture(tex, texture);
		Graphics4::setVertexBuffer(*vb);
		Graphics4::setIndexBuffer(*ib);
		Graphics4::drawIndexedVertices();

		Kore::Graphics4::end();
		Kore::Graphics4::swapBuffers();
	}

	void initGraphics() {
		FileReader vs("g1.vert");
		FileReader fs("g1.frag");
		vertexShader = new Graphics4::Shader(vs.readAll(), vs.size(), Graphics4::VertexShader);
		fragmentShader = new Graphics4::Shader(fs.readAll(), fs.size(), Graphics4::FragmentShader);
		Graphics4::VertexStructure structure;
		structure.add("pos", Graphics4::Float3VertexData);
		structure.add("tex", Graphics4::Float2VertexData);
		pipeline = new Graphics4::PipelineState;
		pipeline->inputLayout[0] = &structure;
		pipeline->inputLayout[1] = nullptr;
		pipeline->vertexShader = vertexShader;
		pipeline->fragmentShader = fragmentShader;
		pipeline->compile();

		tex = pipeline->getTextureUnit("tex");

		texture = new Graphics4::Texture(width, height, Graphics4::Image::RGBA32, false);
		int* image = (int*)texture->lock();
		for (int y = 0; y < texture->texHeight; ++y) {
			for (int x = 0; x < texture->texWidth; ++x) {
				image[y * texture->texWidth + x] = 0;
			}
		}
		texture->unlock();

		// Correct for the difference between the texture's desired size and the actual power of 2 size
		float xAspect = (float)texture->width / texture->texWidth;
		float yAspect = (float)texture->height / texture->texHeight;

		vb = new Graphics4::VertexBuffer(4, structure, Kore::Graphics4::StaticUsage, 0);
		float* v = vb->lock();
		{
			int i = 0;
			v[i++] = -1;
			v[i++] = 1;
			v[i++] = 0.5;
			v[i++] = 0;
			v[i++] = 0;
			v[i++] = 1;
			v[i++] = 1;
			v[i++] = 0.5;
			v[i++] = xAspect;
			v[i++] = 0;
			v[i++] = 1;
			v[i++] = -1;
			v[i++] = 0.5;
			v[i++] = xAspect;
			v[i++] = yAspect;
			v[i++] = -1;
			v[i++] = -1;
			v[i++] = 0.5;
			v[i++] = 0;
			v[i++] = yAspect;
		}
		vb->unlock();

		ib = new Graphics4::IndexBuffer(6);
		int* ii = ib->lock();
		{
			int i = 0;
			ii[i++] = 0;
			ii[i++] = 1;
			ii[i++] = 3;
			ii[i++] = 1;
			ii[i++] = 2;
			ii[i++] = 3;
		}
		ib->unlock();
	}
}

int kore(int argc, char** argv) {
	Kore::System::init("KPU", 640, 480);

	initGraphics();

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
