`timescale 1ns / 1ps

// 8×8비트 부분곱 가산 방식 승산기
// 각 비트 쌍의 AND로 부분곱(partial product) 생성 후 시프트하며 누적
module multiplier_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] out
);
    // 부분곱 배열: pp[i][j] = a[j] & b[i]
    wire [7:0] pp [7:0];

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i+1) begin : GEN_ROW
            for (j = 0; j < 8; j = j+1) begin : GEN_COL
                and_gate u_and (.a(a[j]), .b(b[i]), .out(pp[i][j]));
            end
        end
    endgenerate

    // 부분곱을 비트 시프트하며 순차 누적 (하위 8비트만 사용)
    wire [7:0] sum1, sum2, sum3, sum4, sum5, sum6;

    eight_bit_adder u_add1 (.a(pp[0]),  .b({pp[1][6:0], 1'b0}), .s(sum1));
    eight_bit_adder u_add2 (.a(sum1),   .b({pp[2][5:0], 2'b0}), .s(sum2));
    eight_bit_adder u_add3 (.a(sum2),   .b({pp[3][4:0], 3'b0}), .s(sum3));
    eight_bit_adder u_add4 (.a(sum3),   .b({pp[4][3:0], 4'b0}), .s(sum4));
    eight_bit_adder u_add5 (.a(sum4),   .b({pp[5][2:0], 5'b0}), .s(sum5));
    eight_bit_adder u_add6 (.a(sum5),   .b({pp[6][1:0], 6'b0}), .s(sum6));
    eight_bit_adder u_add7 (.a(sum6),   .b({pp[7][0],   7'b0}), .s(out));

endmodule
