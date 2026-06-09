`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en 
);

    // 타이밍 파라미터
    localparam WAIT_CYCLES = 7'd70;
    localparam CNT_WIDTH = 7;
    
    // 상태 정의
    localparam IDLE = 2'd0, WRITE_MEM = 2'd1, WAIT_PE = 2'd2, COMPUTE = 2'd3;

    // FSM 상태 레지스터와 타이머(카운터)
    reg [1:0] current_state, next_state;
    reg [CNT_WIDTH-1:0] wait_cnt;

    // =========================================================
    // 1. 현재 상태 및 카운터 업데이트
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            wait_cnt <= {CNT_WIDTH{1'b0}};
        end else begin
            current_state <= next_state;
            
            // WAIT_PE 상태에 진입하면 스톱워치 작동 시작
            if (current_state == WAIT_PE && wait_cnt < WAIT_CYCLES) begin
                wait_cnt <= wait_cnt + 1'b1;
            end else if (current_state != WAIT_PE) begin
                wait_cnt <= {CNT_WIDTH{1'b0}};
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
                if (wait_cnt >= WAIT_CYCLES) next_state = COMPUTE;
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
                display_en = 1'b0; // 연산기가 계산하는 동안 화면을 꺼서 쓰레기값 유출 방지
            end
            
            COMPUTE: begin 
                write = 1'b0; 
                display_en = 1'b1; // 대기 시간이 지나 모든 어레이 정답이 확정되면 화면 ON
            end
            
            default: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
        endcase
    end

endmodule
