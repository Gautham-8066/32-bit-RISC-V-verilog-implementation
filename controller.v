// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [1:0] ImmSrc,    // Must be [1:0]
    output [2:0] ALUControl // Must be [2:0]
);

wire [1:0] ALUOp;
wire       Branch;

// The ALU decoder's internal logic will be simplified since we can't pass
// ShiftOp/ShiftType. We will use the same ALUOp definitions as before (2'b10 for R/I-type ALU).
// We'll rely on the ALU to use the instruction bits passed via the datapath.
main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);

// The ALU decoder must also conform to the old port list
alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
assign PCSrc = (Branch & Zero) | Jump;

endmodule
