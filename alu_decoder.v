// alu_decoder.v - logic for ALU decoder
module alu_decoder (
    input            op_5,           // Instruction bit 5 (op[5], 1 for R-type ALU, 0 for I-type ALU)
    input [2:0]      funct3,         // Instruction bits 14:12
    input            funct7_5,       // Instruction bit 30 (bit 5 of funct7)
    input [1:0]      ALUOp,          // Primary ALU operation code from main decoder
    output reg [2:0] ALUControl      // Final ALU operation code (3 bits)
);

// New ALUControl assignments for all operations:
// 3'b000: ADD
// 3'b001: SUB
// 3'b010: AND
// 3'b011: OR
// 3'b100: XOR
// 3'b101: SLT (Signed Less Than)
// 3'b110: SLTU (Unsigned Less Than)
// 3'b111: SHIFT (Shifts must be handled inside the ALU based on funct3/funct7)

always @(*) begin
    ALUControl = 3'bxxx;

    case (ALUOp)
        2'b00: ALUControl = 3'b000;             // ADD (Load/Store/LUI/JALR addresses)
        2'b01: ALUControl = 3'b001;             // SUB (Branch check)
        default:                                // 2'b10: R-type or I-type ALU
            case (funct3)
                3'b000: begin                   // ADD/SUB/ADDI
                    if (funct7_5 & op_5)        // R-type SUB (funct7[5]=1 & op[5]=1)
                        ALUControl = 3'b001;    // SUB
                    else
                        ALUControl = 3'b000;    // ADD/ADDI
                end
                3'b001:  ALUControl = 3'b111;   // SLL/SLLI (Shift Left Logical) - Use SHIFT code
                3'b010:  ALUControl = 3'b101;   // SLT/SLTI (Signed Less Than)
                3'b011:  ALUControl = 3'b110;   // SLTU/SLTIU (Unsigned Less Than)
                3'b100:  ALUControl = 3'b100;   // XOR/XORI
                3'b101:  ALUControl = 3'b111;   // SRL/SRA/SRLI/SRAI (Shift Right) - Use SHIFT code
                3'b110:  ALUControl = 3'b011;   // OR/ORI
                3'b111:  ALUControl = 3'b010;   // AND/ANDI
                default: ALUControl = 3'bxxx;
            endcase
    endcase
end

endmodule
