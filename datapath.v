// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,               // MUST be [1:0]
    input [2:0]   ALUControl,           // MUST be [2:0]
    output        Zero,                 // MUST be 1 bit
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

// Internal signals
wire [31:0] PCNext, PCPlus4, PCTarget_branch; 
wire [31:0] ImmExt, SrcA_Reg, SrcA, SrcB, WriteData, ALUResult;
wire [31:0] ExtendedReadData; 

// --- Internal signals for new instructions ---

// PCSrcA Logic: 1 if instruction is AUIPC (7'b0010111). Needed to mux PC into SrcA
wire PCSrcA = (Instr[6:0] == 7'b0010111);

// JALR Check: 1 if instruction is JALR (7'b1100111)
wire isJALR = (Instr[6:0] == 7'b1100111);

// ALU Funct/Control signals extracted from Instruction
wire [2:0] funct3   = Instr[14:12];
wire funct7b5 = Instr[30];

// ALU result masked for JALR target (JALR target = (rs1 + imm) & ~1)
wire [31:0] ALUResult_JALR_Target = ALUResult & {32{isJALR}} & 32'hFFFFFFFE;
// JAL/Branch target is just PC + ImmExt
wire [31:0] Branch_JAL_Target = PCTarget_branch; 

// PC Target Mux: Selects ALUResult_JALR_Target (if JALR) or Branch_JAL_Target (if Branch/JAL)
wire [31:0] PCTarget_jump;

// --- Core Datapath Logic ---

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget_branch); // PC + Imm for JAL/Branches

// PC Target selection:
// If JALR is active, the masked ALUResult is the next PC.
// Otherwise, use PC + ImmExt (PCTarget_branch) for JAL and Branches.
mux2 #(32)     jump_target_mux(Branch_JAL_Target, ALUResult_JALR_Target, isJALR, PCTarget_jump);

// Final PC Mux: selects between PC+4 (default) and the jump/branch target (PCTarget_jump)
mux2 #(32)     pcmux(PCPlus4, PCTarget_jump, PCSrc, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA_Reg, WriteData);

// IMM Extender - Pass the opcode to distinguish U-type (LUI/AUIPC) from S-type
imm_extend     ext (
    .instr(Instr[31:7]), 
    .immsrc(ImmSrc), 
    .opcode(Instr[6:0]), 
    .immext(ImmExt)
);

// SrcA Mux: selects between register rs1 data (SrcA_Reg) and PC (for AUIPC)
mux2 #(32)     srcamux(SrcA_Reg, PC, PCSrcA, SrcA);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);

// ALU instantiation updated to pass internal instruction fields (funct3 and funct7b5)
alu            alu (
    .a(SrcA), 
    .b(SrcB), 
    .alu_ctrl(ALUControl), 
    .funct3(funct3),       
    .funct7_5(funct7b5),   
    .alu_out(ALUResult), 
    .zero(Zero)
);

// Load extender instance (for lb, lh, lw, lbu, lhu)
load_extender  lex (
    .funct3(funct3),
    .ReadData(ReadData),
    .ExtendedData(ExtendedReadData)
);

// Result Mux (ALU Result, Data from Memory, PC+4)
mux3 #(32)     resultmux(ALUResult, ExtendedReadData, PCPlus4, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule
