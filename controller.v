`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en 
);

    // FSM 상태 및 카운터 레지스터
    reg [1:0] current_state, next_state;
    reg [4:0] wait_cnt; // PE 연산 시간(16클럭)을 세기 위한 카운터

    // 상태 정의: 기존 WRITE_MEM 대신 PE를 기다리는 WAIT_PE 상태로 통합
    localparam IDLE = 2'd0, WAIT_PE = 2'd1, COMPUTE = 2'd2;

    // =========================================================
    // 1. 상태 및 카운터 업데이트 (Sequential Logic)
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            wait_cnt <= 5'd0;
        end else begin
            current_state <= next_state;
            
            // WAIT_PE 상태일 때만 16까지 클럭을 셈
            if (current_state == WAIT_PE && wait_cnt < 5'd16) begin
                wait_cnt <= wait_cnt + 1'b1;
            end
        end
    end

    // =========================================================
    // 2. 다음 상태 결정 (Combinational Logic)
    // =========================================================
    always @(*) begin
        case(current_state)
            IDLE: begin
                if (start) next_state = WAIT_PE;
                else       next_state = IDLE;
            end
            
            WAIT_PE: begin
                // 핵심: PE(SA2x2_CTRL)의 연산 시간인 16클럭을 완벽히 기다림
                if (wait_cnt == 5'd16) next_state = COMPUTE;
                else                   next_state = WAIT_PE;
            end
            
            COMPUTE: begin
                // 연산이 끝났으므로 상태 유지
                next_state = COMPUTE; 
            end
            
            default: next_state = IDLE;
        endcase
    end

    // =========================================================
    // 3. 출력 결정
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
            
            WAIT_PE: begin 
                // 처음 시작할 때 딱 1클럭 동안만 메모리 트리거(write)를 줌
                if (wait_cnt == 5'd0) write = 1'b1;
                else                  write = 1'b0;
                
                //  PE가 계산하는 16클럭 동안 디스플레이 모듈을 꺼둠(Reset 유지)
                display_en = 1'b0; 
            end
            
            COMPUTE: begin 
                write = 1'b0; 
                //  데이터가 고정된 완벽한 타이밍에 디스플레이 ON!
                display_en = 1'b1; 
            end
            
            default: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
        endcase
    end

endmodule
