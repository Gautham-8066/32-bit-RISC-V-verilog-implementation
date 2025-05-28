module prgrmc(pcnext,clk,rst,pc);
input [31:0] pcnext;
input clk,rst;
output reg [31:0]pc;

always @(posedge clk)
begin
    if(rst == 1'b0)
    begin
        pc <= 32'b00000;
    end
    else
    begin
        pc <= pcnext;
    end
end
endmodule