`timescale 1ns / 1ps

// 8비트 가산기 (4비트 가산기 2개로 구성, 하위→상위 올림수 전파)
module eight_bit_adder (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] s
);
    wire c4;  // 하위 4비트 → 상위 4비트 올림수

    // 하위 4비트 덧셈
    four_bit_full_adder_module u_low (
        .a(a[3:0]), .b(b[3:0]), .cin(1'b0),
        .sum(s[3:0]), .cout(c4)
    );

    // 상위 4비트 덧셈
    four_bit_full_adder_module u_high (
        .a(a[7:4]), .b(b[7:4]), .cin(c4),
        .sum(s[7:4]), .cout()
    );

endmodule
