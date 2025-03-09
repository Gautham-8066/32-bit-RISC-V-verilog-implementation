module alu(A,B,Control,Result,Carry,Zero,Negative);
    input[31:0] A,B;
    input[2:0] Control;
    output[31:0] Result;
    output Carry;
    output Zero;
    output Negative;
    wire[31:0] a_n_b;
    wire[31:0] a_or_b;
    wire[31:0] not_b;
    wire[31:0] not_result;
    wire[31:0] mux_1;
    wire[31:0] sum;
    wire[31:0] final__mux;
    wire cout;
    wire alucontrol;


    assign a_n_b= A & B;
    assign a_or_b = A | B;
    assign not_b = ~B;
    assign alucontrol = ~Control[1];
    assign mux_1 = (Control[0] == 1'b 0)?B : not_b ;
    assign {cout,sum} = A + mux_1+Control[0];
    assign Carry = alucontrol & cout;
    assign final__mux= (Control[1:0] == 2'b 00)? sum:
                       (Control[1:0] == 2'b 01)? sum:
                       (Control[1:0] == 2'b 10)? a_n_b: a_or_b;

    assign Result=final__mux;
    assign Zero = (Result == 32'b0) ? 1'b1 : 1'b0;
    assign Negative = Result[31];
    
endmodule
