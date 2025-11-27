// load_extender.v - Handles byte/half-word loading and extension based on funct3
module load_extender (
    input [2:0]  funct3,     // Instruction bits 14:12 for load type
    input [31:0] ReadData,   // Data word read from memory
    output [31:0] ExtendedData // Result written to the register file
);

reg [31:0] data_out;

always @* begin
    case (funct3)
        3'b000: data_out = {{24{ReadData[7]}}, ReadData[7:0]};   // lb (Load Byte, Sign-extended)
        3'b001: data_out = {{16{ReadData[15]}}, ReadData[15:0]}; // lh (Load Half, Sign-extended)
        3'b010: data_out = ReadData;                             // lw (Load Word)
        3'b100: data_out = {{24{1'b0}}, ReadData[7:0]};          // lbu (Load Byte Unsigned, Zero-extended)
        3'b101: data_out = {{16{1'b0}}, ReadData[15:0]};         // lhu (Load Half Unsigned, Zero-extended)
        default: data_out = ReadData;
    endcase
end

assign ExtendedData = data_out;

endmodule
