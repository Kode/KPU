module alu(input rst, input clk, output [31:0] memop, output [31:0] memaddress, output [31:0] memoutdata, input [31:0] memindata);
	reg [31:0] registers [0:31];

	reg [31:0] pc;

	reg [3:0] mode;

	reg [3:0] instruction_mode;

	reg [31:0] instruction;

	always @ (posedge clk) begin
		reg [5:0] opcode;

		reg [25:0] addr;

		reg [4:0] rs;
		reg [4:0] rt;

		reg [15:0] imm;

		reg [4:0] rd;
		//reg [4:0] shamt;
		reg [5:0] func;

		opcode = instruction[31:26];

		addr = instruction[25:0];

		rs = instruction[25:21];
		rt = instruction[20:16];

		imm = instruction[15:0];

		rd = instruction[15:11];
		//shamt = instruction[10:6];
		func = instruction[5:0];

		$display("Mode is %d", mode);

		if (rst == 1) begin
			pc <= 'h400000;
			mode <= 0;
			instruction_mode <= 0;
		end
		else begin
			case (mode)
				0: begin
					$display("Request instruction");
					memaddress <= pc;
					memop <= 1;
					mode <= 1;
				end
				1: begin
					$display("Fetch instruction");
					instruction <= memindata;
					memop <= 0;
					mode <= 2;
				end
				2: begin
					$display("Execute instruction");
					case (opcode)
						6'b0: // special
							case (func)
								6'b100001: begin // addu
									registers[rd] <= registers[rs] + registers[rt];
									pc <= pc + 4;
									mode <= 0;
									$display("addu %d %d %d", rd, rs, rt);
								end
								6'b100000: begin // add
									registers[rd] <= registers[rs] + registers[rt];
									pc <= pc + 4;
									mode <= 0;
									$display("add %d %d %d", rd, rs, rt);
								end
								6'b100010: begin // sub
									registers[rd] <= registers[rs] - registers[rt];
									pc <= pc + 4;
									mode <= 0;
									$display("add %d %d %d", rd, rs, rt);
								end
								6'b101010: begin // slt
									registers[rd] <= (registers[rs] < registers[rt]) ? 1 : 0;
									pc <= pc + 4;
									mode <= 0;
									$display("slt %d %d %d", rd, rs, rt);
								end
								6'b001000: begin // jr
									$display("Jumping back");
									$finish;
								end
								6'b001100: begin // syscall
									$display("syscall");
									pc <= pc + 4;
									mode <= 0;
								end
								default: begin
									$display("Unknown func %b", func);
								end
							endcase
						6'b001000: begin // addi
							registers[rt] <= registers[rs] + {16'b0, imm};
							pc <= pc + 4;
							mode <= 0;
							$display("addi %d %d %d", rt, rs, imm);
						end
						6'b001101: begin // ori
							registers[rt] <= registers[rs] + {16'b0, imm};
							pc <= pc + 4;
							mode <= 0;
							$display("ori %d %d %d", rt, rs, imm);
						end
						6'b001111: begin // lui
							registers[rt] <= {imm, 16'b0};
							pc <= pc + 4;
							mode <= 0;
							$display("lui %d %d", rt, imm);
						end
						6'b101011: begin // sw
							case (instruction_mode)
								0: begin
									memaddress <= registers[rs] + {16'b0, imm};
									memoutdata <= registers[rt];
									memop <= 2;
									instruction_mode <= 1;
									mode <= 2;
									$display("sw (step 1) %d %d %d", rs, imm, rt);
								end
								1: begin
									memop <= 0;
									instruction_mode <= 0;
									pc <= pc + 4;
									mode <= 0;
									$display("sw (step 2) %d %d %d", rs, imm, rt);
								end
							endcase
						end
						6'b100011: begin // lw
							case (instruction_mode)
								0: begin
									memaddress <= registers[rs] + {16'b0, imm};
									memop <= 1;
									instruction_mode <= 1;
									mode <= 2;
									$display("lw (step 1) %d %d %d", rs, imm, rt);
								end
								1: begin
									registers[rt] <= memindata;
									memop <= 0;
									instruction_mode <= 0;
									pc <= pc + 4;
									mode <= 0;
									$display("lw (step 2) %d %d %d", rs, imm, rt);
								end
							endcase
						end
						6'b000100: begin // beq
							if (registers[rt] == registers[rs]) begin
								pc <= pc + 4 + {{14{imm[15]}}, imm, 2'b0};
								mode <= 0;
								$display("beq - jumping %d %d %d", rt, rs, imm);
							end
							else begin
								pc <= pc + 4;
								mode <= 0;
								$display("beq - not jumping %d %d %d", rt, rs, imm);
							end
						end
						6'b000101: begin // bne
							if (registers[rt] != registers[rs]) begin
								pc <= pc + 4 + {{14{imm[15]}}, imm, 2'b0};
								mode <= 0;
								$display("beq - jumping %d %d %d", rt, rs, imm);
							end
							else begin
								pc <= pc + 4;
								mode <= 0;
								$display("beq - not jumping %d %d %d", rt, rs, imm);
							end
						end
						6'b000011: begin // jal
							registers[31] <= pc + 8;
							pc <= {pc[31:28], addr, 2'b0};
							mode <= 0;
							$display("jal %x", addr);
						end
						6'b000010: begin // j
							pc <= {pc[31:28], addr, 2'b0};
							mode <= 0;
							$display("j %x", addr);
						end
						6'b100100: begin // lbu
							case (instruction_mode)
								0: begin
									memaddress <= {16'b0, imm};
									memop <= 1;
									instruction_mode <= 1;
									mode <= 2;
									$display("lbu (step 1) %d %d", rt, imm);
								end
								1: begin
									registers[rt] <= {24'b0, memindata[7:0]};
									memop <= 0;
									instruction_mode <= 0;
									pc <= pc + 4;
									mode <= 0;
									$display("lbu (step 2) %d %d", rt, imm);
								end
							endcase
						end
						default:
							$display("Unknown opcode %b", opcode);
					endcase
				end
			endcase
		end
	end
endmodule
