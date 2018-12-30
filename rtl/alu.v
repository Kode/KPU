module alu(input rst, input clk, output [31:0] memop, output [31:0] memaddress, output [31:0] memoutdata, input [31:0] memindata);
	reg [31:0] registers [0:31];

	reg [31:0] pc;

	reg [3:0] mode;

	reg [31:0] instruction;

	always @ (posedge clk)
	begin
		reg [5:0] opcode;
		reg [4:0] rs;
		reg [4:0] rt;

		reg [15:0] imm;

		reg [4:0] rd;
		reg [4:0] shamt;
		reg [5:0] func;

		opcode = instruction[31:26];
		rs = instruction[25:21];
		rt = instruction[20:16];

		imm = instruction[15:0];

		rd = instruction[15:11];
		shamt = instruction[10:6];
		func = instruction[5:0];

		$display("Mode is %d", mode);

		if (rst == 1)
		begin
			pc <= 32'b0;
			mode <= 4'b0;
		end
		else
		begin
			case (mode)
				0:
					begin
						$display("Request instruction");
						memaddress <= pc;
						memop <= 1;
						mode <= 1;
					end
				1:
					begin
						$display("Fetch instruction");
						instruction <= memindata;
						memop <= 0;
						mode <= 2;
					end
				2:
					begin
						$display("Execute instruction");
						case (opcode)
							6'b0:
								case (func)
									6'b100000: // add
										begin
											registers[rd] <= registers[rs] + registers[rt];
											$display("add %d %d", rs, rt);
										end
									default:
										begin
											$display("Unknown func %d", func);
										end
								endcase
							6'b001000: // addi
								begin
									registers[rt] <= registers[rs] + {16'b0, imm};
									$display("addi %d %d", rs, imm);
								end
							default:
								$display("Unknown opcode %d", opcode);
						endcase

						pc <= pc + 4;
						mode <= 0;
					end
			endcase
		end
	end
endmodule
