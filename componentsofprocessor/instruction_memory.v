module instruction_memory(A,rst,RD);
input [31:0] A;
input rst;
output [31:0] RD;
reg [31:0] mmy [1023:0];

assign RD = (rst == 1'b0)?32'b00000 : mmy[A[31:2]];