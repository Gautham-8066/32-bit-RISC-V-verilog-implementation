// imm_extend.v - logic for sign extension
module imm_extend (
    input  [31:7]     instr,
    input  [ 1:0]     immsrc,
    // We must pass the opcode here to distinguish U-type from S-type
    input  [6:0]      opcode, 
    output reg [31:0] immext
);

// Define U-type opcodes
localparam OP_LUI   = 7'b0110111;
localparam OP_AUIPC = 7'b0010111;

always @(*) begin
    immext = 32'bx;
    case(immsrc)
        // I−type (Load/ALU imm/JALR)
        2'b00:   immext = {{20{instr[31]}}, instr[31:20]};
        
        // S−type (stores) / U−type (LUI/AUIPC)
        2'b01: begin
            if (opcode == OP_LUI || opcode == OP_AUIPC) begin
                // U-Type: Zero extend 20-bit immediate (instr[31:12])
                immext = {instr[31:12], 12'b0};
            end else begin
                // S-Type: Sign extend 12-bit immediate (instr[31:25], instr[11:7])
                immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
        end
        
        // B−type (branches): {imm[12], imm[10:5], imm[4:1], imm[11], 1'b0}
        // instr[31] is imm[12]. instr[7] is imm[11]. instr[30:25] is imm[10:5]. instr[11:8] is imm[4:1].
        2'b10: begin
            immext = {{20{instr[31]}},           // Sign extension from imm[12] (instr[31])
                       instr[7],                 // imm[11]
                       instr[30:25],             // imm[10:5]
                       instr[11:8],              // imm[4:1]
                       1'b0};                    // imm[0] (always 0)
        end
        
        // J−type (jal): {imm[20], imm[10:1], imm[11], imm[19:12], 1'b0}
        // instr[31] is imm[20]. instr[19:12] is imm[19:12]. instr[20] is imm[11]. instr[30:21] is imm[10:1].
        2'b11: begin
            immext = {{12{instr[31]}},           // Sign extension from imm[20] (instr[31])
                       instr[31],                // imm[20]
                       instr[19:12],             // imm[19:12]
                       instr[20],                // imm[11]
                       instr[30:21],             // imm[10:1]
                       1'b0};                    // imm[0] (always 0)
        end
        
        default: immext = 32'bx; // undefined
    endcase
end

endmodule
