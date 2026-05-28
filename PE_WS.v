`timescale 1ns / 1ps

// Weight Stationary PE (3×3 시스톨릭 어레이용)
// 동작: out = sin + din×win  (가중치 고정, 부분합은 위→아래 전파)
//       dout = din           (입력 데이터를 오른쪽 PE로 전달)
module PE_WS (
    input        clk, rst, clear,
    input  [7:0] din, win, sin,
    output reg [7:0] dout,
    output reg [7:0] out
);
    wire [7:0] mult_result;

    // 곱셈기 인스턴스
    multiplier_8bit u_mult (.a(din), .b(win), .out(mult_result));

    // 클럭 상승 엣지에 데이터 전달 및 부분합 누적
    always @(posedge clk or negedge rst) begin
        if (!rst || clear) begin
            dout <= 8'd0;
            out  <= 8'd0;
        end else begin
            dout <= din;               // 데이터 오른쪽으로 전달
            out  <= sin + mult_result; // 부분합 아래로 전달
        end
    end

endmodule
