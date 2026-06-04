`timescale 1ns / 1ps

// 4비트 리플 캐리 가산기 (전가산기 4개 직렬 연결)
module four_bit_full_adder_module (a, b, cin, sum, cout);
    input  [3:0] a, b;
    input        cin;
    output [3:0] sum;
    output       cout;

    // 비트 간 올림수 연결 와이어
    wire cout_1, cout_2, cout_3;

    // 하위 비트부터 순서대로 전가산기 연결
    full_adder_gatelevel_module fa0 (.a(a[0]), .b(b[0]), .cin(cin),    .sum(sum[0]), .cout(cout_1));
    full_adder_gatelevel_module fa1 (.a(a[1]), .b(b[1]), .cin(cout_1), .sum(sum[1]), .cout(cout_2));
    full_adder_gatelevel_module fa2 (.a(a[2]), .b(b[2]), .cin(cout_2), .sum(sum[2]), .cout(cout_3));
    full_adder_gatelevel_module fa3 (.a(a[3]), .b(b[3]), .cin(cout_3), .sum(sum[3]), .cout(cout));

endmodule
