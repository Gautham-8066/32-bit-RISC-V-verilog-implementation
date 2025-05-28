

module alu(A,B,Control,Result);
    input[31:0] A,B;
    input[2:0] Control;
    output[31:0] Result;
    wire[31:0] a_n_b;
    wire[31:0] a_or_b;
    wire[31:0] not_b;
    wire[31:0] mux_1;
    wire[31:0] sum;
    wire[31:0] final__mux;

    assign a_n_b= A & B;
    assign a_or_b = A | B;
    assign not_b = ~B;
    assign mux_1 = (Control[0] == 1b'0) ?B : not_b;
    assign sum = A + mux_1+Control[0];
    assign final__mux= (Control[1:0] == 2b'00)? sum:
                       (Control[1:0] == 2b'01)? sum:
                       (Control[1:0] == 2b'10)? a_n_b: a_or_b;

    assign Result=final__mux

end module