`timescale 1ns / 1ps

// 1비트 전가산기 (게이트 레벨 구조적 모델링)
// sum = a ^ b ^ cin,  cout = (a&b) | (b&cin) | (a&cin)
module full_adder_gatelevel_module (a, b, cin, sum, cout);
    input  a, b, cin;
    output sum, cout;

    // 내부 와이어
    wire xor_out_1;
    wire and_out_1, and_out_2, and_out_3;
    wire or_out_1;

    // 합(sum) 계산: a ^ b ^ cin
    xor_gate xor_1 (.a(a),        .b(b),   .out(xor_out_1));
    xor_gate xor_2 (.a(xor_out_1),.b(cin), .out(sum));

    // 올림수(cout) 계산: (a&b) | (b&cin) | (a&cin)
    and_gate and_1 (.a(a), .b(b),   .out(and_out_1));
    and_gate and_2 (.a(b), .b(cin), .out(and_out_2));
    and_gate and_3 (.a(a), .b(cin), .out(and_out_3));
    or_gate  or_1  (.a(and_out_1), .b(and_out_2), .out(or_out_1));
    or_gate  or_2  (.a(or_out_1),  .b(and_out_3), .out(cout));

endmodule
