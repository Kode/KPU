const project = new Project('KPU');

project.addFiles('driver/**');
project.addFiles('obj_dir/**');

project.addIncludeDir('verilator/include');
project.addFiles('verilator/include/verilated.cpp');

project.kore = false;
project.cmd = true;

project.setDebugDir('asm');

resolve(project);
