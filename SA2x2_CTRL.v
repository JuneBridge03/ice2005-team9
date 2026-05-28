`timescale 1ns / 1ps

// 2×2 시스톨릭 어레이 컨트롤러
// 스큐(skewed) 데이터 스케줄링으로 4개 컨볼루션 출력을 동시 계산
// 커널은 180° 뒤집혀 있으므로 ker[2][0]→ker[0][2] 순으로 공급
module SA2x2_CTRL (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    input  [7:0]   pe_out_1, pe_out_2, pe_out_3, pe_out_4,
    output reg       pe_clr,
    output reg [7:0] filter1, filter2, in1, in2,
    output reg [7:0] c11, c12, c21, c22,
    output reg       done
);
    reg  [5:0] clk_counter;

    // 입력 이미지 / 커널 언패킹
    wire [7:0] img [0:3][0:3];
    wire [7:0] ker [0:2][0:2];

    genvar r, c;
    generate
        for (r = 0; r < 4; r = r+1) begin : img_mapping
            for (c = 0; c < 4; c = c+1) begin : img_col
                assign img[r][c] = flat_image[127 - (r*4+c)*8 -: 8];
            end
        end
        for (r = 0; r < 3; r = r+1) begin : ker_mapping
            for (c = 0; c < 3; c = c+1) begin : ker_col
                assign ker[r][c] = flat_kernel[71 - (r*3+c)*8 -: 8];
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            clk_counter <= 0; done <= 0; pe_clr <= 1;
            c11 <= 0; c12 <= 0; c21 <= 0; c22 <= 0;
            filter1 <= 0; filter2 <= 0; in1 <= 0; in2 <= 0;
        end else if (!done) begin
            pe_clr <= 0;
            clk_counter <= clk_counter + 1;

            // 스큐 데이터 공급 스케줄 (사이클 1~13)
            case (clk_counter)
                1:  begin in1 <= img[0][3]; in2 <= 0; end
                2:  begin filter1 <= ker[2][0]; filter2 <= ker[2][0]; in1 <= img[0][2]; in2 <= img[1][3]; end
                3:  begin filter1 <= ker[2][1]; filter2 <= ker[2][1]; in1 <= img[0][1]; in2 <= img[1][2]; end
                4:  begin filter1 <= ker[2][2]; filter2 <= ker[2][2]; in1 <= img[0][0]; in2 <= img[1][1]; end
                5:  begin filter1 <= 0;          filter2 <= 0;          in1 <= img[1][3]; in2 <= img[1][0]; end
                6:  begin filter1 <= ker[1][0]; filter2 <= ker[1][0]; in1 <= img[1][2]; in2 <= img[2][3]; end
                7:  begin filter1 <= ker[1][1]; filter2 <= ker[1][1]; in1 <= img[1][1]; in2 <= img[2][2]; end
                8:  begin filter1 <= ker[1][2]; filter2 <= ker[1][2]; in1 <= img[1][0]; in2 <= img[2][1]; end
                9:  begin filter1 <= 0;          filter2 <= 0;          in1 <= img[2][3]; in2 <= img[2][0]; end
                10: begin filter1 <= ker[0][0]; filter2 <= ker[0][0]; in1 <= img[2][2]; in2 <= img[3][3]; end
                11: begin filter1 <= ker[0][1]; filter2 <= ker[0][1]; in1 <= img[2][1]; in2 <= img[3][2]; end
                12: begin filter1 <= ker[0][2]; filter2 <= ker[0][2]; in1 <= img[2][0]; in2 <= img[3][1]; end
                13: begin filter1 <= 0;          filter2 <= 0;          in1 <= 0;          in2 <= img[3][0]; end

                // 결과 캡처 (PE 파이프라인 딜레이 반영)
                15: begin c11 <= pe_out_1; c12 <= pe_out_2; end
                16: begin c21 <= pe_out_3; c22 <= pe_out_4; done <= 1; end

                default: begin filter1 <= 0; filter2 <= 0; in1 <= 0; in2 <= 0; end
            endcase
        end
    end

endmodule
