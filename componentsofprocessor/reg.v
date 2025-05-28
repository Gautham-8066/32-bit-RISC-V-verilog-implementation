module reg(A1,A2,A3,WD3,WE3,clk,rst,RD1,RD2);

input[4:0] A1,A2,A3;
input WE3,clk,rst;
input [31:0] WD3;
output reg [31:0] RD1,RD2;

reg [31:0] registers [31:0];
assign RD1 = (!rst) ? 32'b00000 : registers[A1];
assign RD2 = (!rst) ? 32'b00000 : registers[A2];

always @(posedge clk)
begin 
    if (WE3)
    registers[A3] <= WD3;
end
end module