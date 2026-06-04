`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en 
);

    // FSM 상태 레지스터와 타이머(카운터)
    reg [1:0] current_state, next_state;
    reg [4:0] wait_cnt; // PE 연산 시간(16클럭)을 속으로 세기 위한 스톱워치

    // 상태 정의
    localparam IDLE = 2'd0, WRITE_MEM = 2'd1, WAIT_PE = 2'd2, COMPUTE = 2'd3;

    // =========================================================
    // 1. 현재 상태 및 카운터 업데이트
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            wait_cnt <= 5'd0;
        end else begin
            current_state <= next_state;
            
            // WAIT_PE 상태에 진입하면 스톱워치 작동 시작 (16까지 셈)
            if (current_state == WAIT_PE && wait_cnt < 5'd16) begin
                wait_cnt <= wait_cnt + 1'b1;
            end
        end
    end

    // =========================================================
    // 2. 다음 상태 결정
    // =========================================================
    always @(*) begin
        case(current_state)
            IDLE: begin
                if (start) next_state = WRITE_MEM;
                else       next_state = IDLE;
            end
            
            WRITE_MEM: begin
                next_state = WAIT_PE; // 메모리에 신호 주고 바로 대기 모드 돌입
            end
            
            WAIT_PE: begin
                // 🚀 핵심: 외부 신호를 받을 필요 없이 속으로 16클럭을 셉니다!
                if (wait_cnt >= 5'd16) next_state = COMPUTE;
                else                   next_state = WAIT_PE;
            end
            
            COMPUTE: begin
                next_state = COMPUTE; // 디스플레이 켠 상태 무한 유지
            end
            
            default: next_state = IDLE;
        endcase
    end

    // =========================================================
    // 3. 출력 결정 (타이밍 제어)
    // =========================================================
    always @(*) begin
        // 기본값 할당
        write = 1'b0;
        display_en = 1'b0;

        case(current_state)
            IDLE: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
            
            WRITE_MEM: begin 
                write = 1'b1; // 딱 1클럭 동안 메모리에 출발 신호 쏨
                display_en = 1'b0; 
            end
            
            WAIT_PE: begin 
                write = 1'b0; 
                display_en = 1'b0; // 🚀 연산기가 계산하는 16클럭 동안 화면을 꺼서 쓰레기값 유출 방지!
            end
            
            COMPUTE: begin 
                write = 1'b0; 
                display_en = 1'b1; // 🚀 16클럭이 지나 정답이 확정되면 그제야 화면 ON!
            end
            
            default: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
        endcase
    end

endmodule
