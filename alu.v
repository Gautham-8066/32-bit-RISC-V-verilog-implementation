// alu.v - ALU module
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [2:0] alu_ctrl,         // ALU control
    input       [2:0] funct3,           // Instruction bits [14:12] from Datapath
    input               funct7_5,       // Instruction bit [30] from Datapath
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                    // zero flag (overloaded as Branch condition flag when needed)
);

// For R-type and I-type shifts, the shift amount is in b[4:0] (5 bits)
wire [4:0] shamt = b[4:0];

// Comparison Wires for Branch Logic
wire equal = (a == b);
wire signed_lt = ($signed(a) < $signed(b));
wire signed_ge = ($signed(a) >= $signed(b));
wire unsigned_lt = (a < b);
wire unsigned_ge = (a >= b);
reg  branch_comp_result; // Holds the result of a specific branch comparison

always @* begin
    alu_out = 32'bx;
    branch_comp_result = 1'b0;

    // Check for branch condition when in SUB mode (ALUControl=3'b001 is set by Main Decoder for all branches)
    if (alu_ctrl == 3'b001) begin
        case (funct3)
            3'b000: branch_comp_result = equal;      // BEQ (rs1 == rs2)
            3'b001: branch_comp_result = !equal;     // BNE (rs1 != rs2)
            3'b100: branch_comp_result = signed_lt;  // BLT (rs1 < rs2, signed)
            3'b101: branch_comp_result = signed_ge;  // BGE (rs1 >= rs2, signed)
            3'b110: branch_comp_result = unsigned_lt;// BLTU (rs1 < rs2, unsigned)
            3'b111: branch_comp_result = unsigned_ge;// BGEU (rs1 >= rs2, unsigned)
            default: branch_comp_result = 1'b0;      // Should be SUB
        endcase
    end
    
    // ALU Operation logic
    case (alu_ctrl)
        3'b000:  alu_out = a + b;            // ADD, ADDI, Address calc
        3'b001:  alu_out = a - b;            // SUB, Branch checks (ALU result is ignored, Zero is used)
        3'b010:  alu_out = a & b;            // AND, ANDI
        3'b011:  alu_out = a | b;            // OR, ORI
        3'b100:  alu_out = a ^ b;            // XOR, XORI
        3'b101:  alu_out = signed_lt ? 32'd1 : 32'd0;    // SLT, SLTI (Signed)
        3'b110:  alu_out = unsigned_lt ? 32'd1 : 32'd0;  // SLTU, SLTIU (Unsigned)
        3'b111:  begin                       // SHIFT (SLL, SRL, SRA)
            case (funct3)
                3'b001: alu_out = a << shamt;                 // SLL/SLLI
                3'b101: begin
                    if (funct7_5)                             // SRA/SRAI (funct7[5]=1)
                        alu_out = $signed(a) >>> shamt;       // Arithmetic Shift Right
                    else
                        alu_out = a >> shamt;                 // SRL/SRLI (Logical Shift Right)
                end
                default: alu_out = 32'bx;
            endcase
        end
        default: alu_out = 32'bx;
    endcase
end

// Output for Zero: If ALU is in branch mode, output the comparison result.
// Otherwise, output if alu_out is zero.
assign zero = (alu_ctrl == 3'b001) ? branch_comp_result : (alu_out == 0);

endmodule
