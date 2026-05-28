`timescale 1ns / 1ps

module Controller (
    input clk,          // 클럭 신호 
    input rst,          // 리셋 신호
    input start,        // 연산 시작 외부 트리거 (테스트벤치에서 인가)
    output reg write,   // 메모리 입력(Write) 활성화 신호 
    output reg display_en // 디스플레이 활성화 신호 
);

    reg [1:0] state;
    localparam IDLE = 2'b00, WRITE_MEM = 2'b01, COMPUTE = 2'b10;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            write <= 1'b0;
            display_en <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    write <= 1'b0;
                    display_en <= 1'b0;
                    if (start) state <= WRITE_MEM;
                end
                WRITE_MEM: begin
                    write <= 1'b1;        // 딱 1클럭 동안만 메모리에 Write 인가
                    display_en <= 1'b0;
                    state <= COMPUTE;
                end
                COMPUTE: begin
                    write <= 1'b0;        // 연산 중에는 메모리 덮어쓰기 방지
                    display_en <= 1'b1;   // 연산 결과 출력 활성화
                    // 연산 완료 신호(done)를 받으면 다시 IDLE로 돌아가는 로직을 추가할 수 있습니다.
                end
            endcase
        end
    end
endmodule
