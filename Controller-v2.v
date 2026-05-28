`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          // 외부(테스트벤치) 연산 시작 신호
    output reg write,     // 메모리 입력 활성화 신호 
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
                    write <= 1'b1;        // 딱 1클럭 동안만 메모리 Write 활성화
                    display_en <= 1'b0;
                    state <= COMPUTE;
                end
                COMPUTE: begin
                    write <= 1'b0;        // 연산 중에는 덮어쓰기 방지
                    display_en <= 1'b1;   
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
