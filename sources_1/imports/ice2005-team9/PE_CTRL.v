`timescale 1ns / 1ps

// Single PE 컨트롤러 (직렬 모드 FSM)
// C11→C12→C21→C22 순서로 4개의 컨볼루션 출력을 순차 계산
// 각 출력마다: 1사이클 클리어 + 9사이클 MAC + 1사이클 대기 + 1사이클 캡처
module PE_CTRL (
    input        clk, rst,
    input  [127:0] flat_image,
    input  [71:0]  flat_kernel,
    input  [7:0]   pe_out,
    output reg     pe_clr,
    output reg [7:0] pe_din, pe_win,
    output reg [7:0] c11_pe, c12_pe, c21_pe, c22_pe,
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

    // 타이밍 파라미터
    localparam MAC_CYCLES = 4'd9;
    localparam PIPELINE_DELAY = 4'd1;
    localparam CLEAR_CYCLE = 4'd1;
    localparam TOTAL_CYCLES = MAC_CYCLES + PIPELINE_DELAY + CLEAR_CYCLE;
    localparam NUM_OUTPUTS = 3'd4;
    
    reg [3:0] cnt;
    reg [2:0] state; // 0~3: 출력 인덱스(C11~C22), 4: 완료

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt   <= 0; state <= 0; pe_clr <= 1; done <= 0;
            {c11_pe, c12_pe, c21_pe, c22_pe} <= 0;
            pe_din <= 0; pe_win <= 0;
        end else begin
            case (state)
                0, 1, 2, 3: begin
                    if (cnt == 0) begin
                        // 클리어 사이클: PE 누산기 초기화
                        pe_clr <= 1;
                        cnt    <= cnt + 1;
                    end else if (cnt <= MAC_CYCLES) begin
                        // MAC 사이클: 9개 원소 순서대로 곱셈누산
                        pe_clr <= 0;
                        pe_win <= ker[2 - (cnt-1)/3][2 - (cnt-1)%3]; // 180° 뒤집힌 커널
                        case (state)
                            0: pe_din <= img[(cnt-1)/3]  [(cnt-1)%3];       // C11 윈도우
                            1: pe_din <= img[(cnt-1)/3]  [((cnt-1)%3)+1];   // C12 윈도우
                            2: pe_din <= img[((cnt-1)/3)+1][(cnt-1)%3];     // C21 윈도우
                            3: pe_din <= img[((cnt-1)/3)+1][((cnt-1)%3)+1]; // C22 윈도우
                        endcase
                        cnt <= cnt + 1;
                    end else if (cnt == MAC_CYCLES + CLEAR_CYCLE) begin
                        // 파이프라인 레이턴시 대기
                        cnt <= cnt + 1;
                    end else begin
                        // 결과 캡처
                        case (state)
                            0: c11_pe <= pe_out;
                            1: c12_pe <= pe_out;
                            2: c21_pe <= pe_out;
                            3: c22_pe <= pe_out;
                        endcase
                        cnt   <= 0;
                        state <= state + 1;
                    end
                end
                NUM_OUTPUTS: done <= 1; // 모든 출력 완료
            endcase
        end
    end

endmodule
