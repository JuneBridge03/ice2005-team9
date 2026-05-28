`timescale 1ns / 1ps

// 3×3 시스톨릭 어레이 컨트롤러
// 스큐 데이터 스케줄링으로 C11/C12/C21/C22를 파이프라인 방식으로 계산
// 가중치는 180° 뒤집어 고정 할당, 결과는 cnt==6/9/12/15 사이클에 캡처
module SA3x3_CTRL (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    input  [7:0]   sout20, sout21, sout22, // SA3x3 최하단 행 출력
    output reg     pe_clr,
    output reg [7:0] r_din0, r_din1, r_din2,
    output [7:0] w00, w01, w02, w10, w11, w12, w20, w21, w22, // 고정 가중치
    output reg [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3,
    output reg     done
);
    // 입력 이미지 / 커널 언패킹
    wire [7:0] img [0:3][0:3], ker [0:2][0:2];
    genvar r, c;
    generate
        for (r = 0; r < 4; r = r+1) for (c = 0; c < 4; c = c+1)
            assign img[r][c] = flat_image[127-(r*4+c)*8 -: 8];
        for (r = 0; r < 3; r = r+1) for (c = 0; c < 3; c = c+1)
            assign ker[r][c] = flat_kernel[71-(r*3+c)*8 -: 8];
    endgenerate

    // 가중치 180° 뒤집어 각 PE에 정적 할당
    assign w00=ker[2][2]; assign w01=ker[2][1]; assign w02=ker[2][0];
    assign w10=ker[1][2]; assign w11=ker[1][1]; assign w12=ker[1][0];
    assign w20=ker[0][2]; assign w21=ker[0][1]; assign w22=ker[0][0];

    reg [5:0] cnt;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 0; pe_clr <= 1; done <= 0;
            {c11_3x3, c12_3x3, c21_3x3, c22_3x3} <= 0;
            r_din0 <= 0; r_din1 <= 0; r_din2 <= 0;
        end else begin
            pe_clr <= 0;
            cnt    <= cnt + 1;

            // 스큐 데이터 공급 스케줄 (행별 1사이클 오프셋)
            case (cnt)
                0:  begin r_din0 <= img[0][2]; r_din1 <= 8'd0;      r_din2 <= 8'd0;      end
                1:  begin r_din0 <= img[0][1]; r_din1 <= img[1][2]; r_din2 <= 8'd0;      end
                2:  begin r_din0 <= img[0][0]; r_din1 <= img[1][1]; r_din2 <= img[2][2]; end
                3:  begin r_din0 <= img[0][3]; r_din1 <= img[1][0]; r_din2 <= img[2][1]; end
                4:  begin r_din0 <= img[0][2]; r_din1 <= img[1][3]; r_din2 <= img[2][0]; end
                5:  begin r_din0 <= img[0][1]; r_din1 <= img[1][2]; r_din2 <= img[2][3]; end
                6:  begin r_din0 <= img[1][2]; r_din1 <= img[1][1]; r_din2 <= img[2][2]; end
                7:  begin r_din0 <= img[1][1]; r_din1 <= img[2][2]; r_din2 <= img[2][1]; end
                8:  begin r_din0 <= img[1][0]; r_din1 <= img[2][1]; r_din2 <= img[3][2]; end
                9:  begin r_din0 <= img[1][3]; r_din1 <= img[2][0]; r_din2 <= img[3][1]; end
                10: begin r_din0 <= img[1][2]; r_din1 <= img[2][3]; r_din2 <= img[3][0]; end
                11: begin r_din0 <= img[1][1]; r_din1 <= img[2][2]; r_din2 <= img[3][3]; end
                12: begin r_din0 <= 8'd0;      r_din1 <= img[2][1]; r_din2 <= img[3][2]; end
                13: begin r_din0 <= 8'd0;      r_din1 <= 8'd0;      r_din2 <= img[3][1]; end
                default: begin r_din0 <= 0; r_din1 <= 0; r_din2 <= 0; end
            endcase

            // 파이프라인 출력 캡처: 3열 부분합 합산 = 해당 출력 픽셀
            if (cnt == 6)  c11_3x3 <= sout20 + sout21 + sout22;
            if (cnt == 9)  c12_3x3 <= sout20 + sout21 + sout22;
            if (cnt == 12) c21_3x3 <= sout20 + sout21 + sout22;
            if (cnt == 15) begin
                c22_3x3 <= sout20 + sout21 + sout22;
                done <= 1;
            end
        end
    end

endmodule
