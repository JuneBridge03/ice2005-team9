`timescale 1ns / 1ps

// 순수 데이터 저장 및 Flat Vector 출력 메모리
module memory (
    input clk, 
    input rst, 
    input write, // 컨트롤러에서 오는 저장 신호
    
    // 개별 8비트 입력 (4x4 이미지)
    input [7:0] A11, A12, A13, A14,
    input [7:0] A21, A22, A23, A24,
    input [7:0] A31, A32, A33, A34,
    input [7:0] A41, A42, A43, A44,
    
    // 개별 8비트 입력 (3x3 커널/필터)
    input [7:0] F11, F12, F13,
    input [7:0] F21, F22, F23,
    input [7:0] F31, F32, F33,

    // TOP_Convolution이 요구하는 통짜(Flat) 출력 양식
    output reg [127:0] flat_image,
    output reg [71:0]  flat_kernel
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            flat_image  <= 128'd0;
            flat_kernel <= 72'd0;
        end 
        else if (write) begin
            // 16개의 8비트 데이터를 128비트 하나로 이어 붙임 (Concatenation)
            // 주의: 팀원의 PE_CTRL 언패킹 순서에 맞춰서 11부터 44까지 순서대로 배치
            flat_image <= { A11, A12, A13, A14, 
                            A21, A22, A23, A24, 
                            A31, A32, A33, A34, 
                            A41, A42, A43, A44 };
                            
            // 9개의 8비트 데이터를 72비트 하나로 이어 붙임
            flat_kernel <= { F11, F12, F13, 
                             F21, F22, F23, 
                             F31, F32, F33 };
        end
    end

endmodule
