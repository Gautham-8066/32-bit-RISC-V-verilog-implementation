module data_mem(A,clk,WE,RD,WD);
input [31:0] A,WD;
input clk,WE;
output reg [31:0] RD;

reg [31:0] mem [31:0];

assign RD = (WE == 1'b0) ? mem[A]: 32'b00000;

always @(posedge clk)
begin 
    if (WE)
    mem[A] <= WD;
end
endmodule