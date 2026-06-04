`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en,
    output reg calc_rst    // 🚀 [추가] 연산기를 꽉 잡고 있을 전용 리셋 신호
);

    // FSM 상태 레지스터와 타이머(카운터)
    reg [1:0] current_state, next_state;
    reg [4:0] wait_cnt; // PE 연산 시간(16클럭)을 속으로 세기 위한 스톱워치

    // 상태 정의
    localparam IDLE = 2'd0, WAIT_PE = 2'd1, COMPUTE = 2'd2;

    // =========================================================
    // 1. 현재 상태 및 카운터 업데이트 (Sequential Logic)
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
            end else if (current_state != WAIT_PE) begin
                wait_cnt <= 5'd0; // 다른 상태로 가면 카운터 초기화
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
                // 16클럭을 다 세면 COMPUTE(출력) 상태로 넘어감
                if (wait_cnt >= 5'd16) next_state = COMPUTE;
                else                   next_state = WAIT_PE;
            end
            
            COMPUTE: begin
                // 연산과 출력이 안정화되었으므로 상태 유지
                next_state = COMPUTE; 
            end
            
            default: next_state = IDLE;
        endcase
    end

    // =========================================================
    // 3. 출력 결정 (Moore Machine / 타이밍 제어)
    // =========================================================
    always @(*) begin
        // 기본값 할당 (Latch 생성 방지)
        write = 1'b0;
        display_en = 1'b0;
        calc_rst = 1'b1; //  기본적으로 연산기를 리셋 상태로 꽉 묶어둠

        case(current_state)
            IDLE: begin 
                write = 1'b0;
                display_en = 1'b0;
                calc_rst = 1'b1; // 대기 중에는 연산 금지
            end
            
            WAIT_PE: begin 
                if (wait_cnt == 5'd0) write = 1'b1; // 첫 1클럭에만 메모리 켬
                else                  write = 1'b0;
                
                calc_rst = 1'b0; //  메모리에서 데이터가 나가는 순간 연산기 리셋 해제! (연산 시작)
                display_en = 1'b0; // 16클럭 동안 화면은 끔
            end
            
            COMPUTE: begin 
                write = 1'b0; 
                calc_rst = 1'b0; // 연산 끝났거나 진행 중일 때 계속 해제 상태 유지
                display_en = 1'b1; //  정답이 완성되었으므로 디스플레이 ON
            end
            
            default: begin
                write = 1'b0;
                display_en = 1'b0;
                calc_rst = 1'b1;
            end
        endcase
    end

endmodule
