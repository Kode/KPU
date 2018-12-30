module alu(input rst, input clk, reg [31:0] instruction, output reg [31:0] out);

	reg [31:0] registers [0:31];

	//reg [31:0] pc;

	always @ (posedge clk or negedge rst)
	begin
		reg [5:0] opcode;
		reg [4:0] rs;
		reg [4:0] rt;
		reg [4:0] rd;
		reg [4:0] shamt;
		reg [5:0] func;

		opcode = instruction[5:0];
		rs = instruction[10:6];
		rt = instruction[15:11];
		rd = instruction[20:16];
		shamt = instruction[25:21];
		func = instruction[31:26];

		case (opcode)
			6'b0:
				case (func)
					6'b1:
						begin
						registers[rd] <= registers[rs] + {27'b0, rt};
						$display("addi");
						end
					default:
						begin
						out <= 0;
						$display("default");
						end
				endcase
			default:
				registers[0] <= 32'b0;
		endcase
	end
endmodule
