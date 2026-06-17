`timescale 1ns / 1ps

// 1비트 레지스터 (비동기 액티브-로우 리셋, 비헤이비어 모델링)
module one_bit_register_behavioral_module (in, clk, rst, en, out);
    input  in, clk, rst, en;
    output reg out;

    // 상승 엣지 클럭 / 상승 엣지 리셋
    always @(posedge clk or posedge rst) begin
        if (rst)    out <= 1'b0;
        else if (en) out <= in;
    end

endmodule
