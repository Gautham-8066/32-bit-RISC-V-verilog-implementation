module main_decoder(op,zero,RegWrite,MemWrite,ResultSrc,ALUSrc,ImSrc,,ALUOp,PCSrc)
    input zero;
    input [6:0] op;
    output reg RegWrite,MemWrite,ResultSrc,ALUSrc,PCSSrc;
    output reg [1:0] ImSrc,ALUOp;

    wire branch;
    assign RegWrite = (op == 7'b0110011) || (op == 7'b0000011)) ? 1 b'1 : 1'b0; //1 for activation and 0 for deactivation
    assign MemWrite = (op == 7'b0100011) ? 1 b'1 : 1'b0;
    assign ALUSrc = (op == 7'b0000011) || (op == 7'b0100011) ? 1 b'1 : 1'b0;
    assign branch = (op == 7'b1100011) ? 1 b'1 : 1'b0;
    assign ResultSrc = (op == 7'b0000011) ? 1 b'1 : 1'b0;
    assign ImSrc = (op == 7'b0100011) ? 2'b01 : 
                   (op == 7'b1100011) ? 2'b10 :
                   2'b00; // default

    assign ALUOp = (op == 7'b0110011) ? 2'b10 : 
                   (op == 7'b1100011) ? 2'b01 :
                   2'b00; // default
    assign PCSrc = branch & zero ; 
end module