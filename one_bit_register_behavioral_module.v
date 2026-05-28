`timescale 1ns / 1ps

// 1비트 레지스터 (비동기 액티브-로우 리셋, 비헤이비어 모델링)
module one_bit_register_behavioral_module (in, clk, rst, out);
    input  in, clk, rst;
    output reg out;

    // 상승 엣지 클럭 / 하강 엣지 리셋
    always @(posedge clk or negedge rst) begin
        if (!rst) out <= 1'b0;
        else      out <= in;
    end

endmodule
