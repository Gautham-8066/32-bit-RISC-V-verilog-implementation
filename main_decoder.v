// main_decoder.v - logic for main decoder
module main_decoder (
    input  [6:0] op,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,
    output [1:0] ImmSrc,    // Restricted to 2 bits
    output [1:0] ALUOp
);

// Control word: RegWrite_ImmSrc[1:0]_ALUSrc_MemWrite_ResultSrc[1:0]_Branch_ALUOp[1:0]_Jump (11 bits)
// ResultSrc: 00=ALU, 01=MEM, 10=PC+4 (for Jumps)
reg [10:0] controls;

always @(*) begin
    case (op)
        // Opcode:           R_ImmSrc_ASrc_MW_RSrc_B_AOp_J
        7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // Load (I-type, SrcB=Imm, Result=Mem)
        7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // Store (S-type, SrcB=Imm, MemWrite=1)
        7'b0110011: controls = 11'b1_00_0_0_00_0_10_0; // R–type ALU (R-type, SrcB=rs2)
        7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // Branch (B-type, SrcB=rs2, ALUOp=SUB)
        7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU (I-type, SrcB=Imm)
        
        // U-Type: LUI/AUIPC uses S-type slot (2'b01) for ImmSrc
        // LUI: ALUOp=ADD, SrcA=0. ResultSrc=ALU.
        // AUIPC: ALUOp=ADD, SrcA=PC (handled in datapath). ResultSrc=ALU.
        7'b0010111: controls = 11'b1_01_1_0_00_0_00_0; // auipc (U-type ImmSrc, SrcB=Imm)
        7'b0110111: controls = 11'b1_01_1_0_00_0_00_0; // lui (U-type ImmSrc, SrcB=Imm)
        
        // Jump Instructions
        7'b1100111: controls = 11'b1_00_1_0_10_0_00_1; // jalr (I-type, SrcB=Imm, ResultSrc=PC+4, Jump=1)
        7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal (J-type, SrcB=rs2(0), ResultSrc=PC+4, Jump=1)
        
        default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // Undefined
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

endmodule
