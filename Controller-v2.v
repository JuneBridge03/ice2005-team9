`timescale 1ns / 1ps

module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en 
);

    // FSM 상태 레지스터
    reg [1:0] current_state, next_state;

    // 상태 정의
    localparam IDLE = 2'd0, WRITE_MEM = 2'd1, COMPUTE = 2'd2;

    // =========================================================
    // 1. 현재 상태 업데이트 (Sequential Logic)
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // =========================================================
    // 2. 다음 상태 결정 (Combinational Logic)
    // =========================================================
    always @(*) begin
        case(current_state)
            IDLE: begin
                if (start) next_state = WRITE_MEM;
                else       next_state = IDLE;
            end
            
            WRITE_MEM: begin
                next_state = COMPUTE; // 1클럭 동안만 쓰고 바로 연산 상태로 넘어감
            end
            
            COMPUTE: begin
                // 연산이 끝날 때까지 유지 (임시로 COMPUTE 유지, 필요시 종료 조건 추가 가능)
                next_state = COMPUTE; 
            end
            
            default: next_state = IDLE;
        endcase
    end

    // =========================================================
    // 3. 출력 결정 (Moore Machine: 오직 current_state에만 의존)
    // =========================================================
    always @(*) begin
        // 기본값 할당 (Latch 방지)
        write = 1'b0;
        display_en = 1'b0;

        case(current_state)
            IDLE: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
            
            WRITE_MEM: begin 
                write = 1'b1; // 메모리에 데이터 저장
                display_en = 1'b0; 
            end
            
            COMPUTE: begin 
                write = 1'b0; // 덮어쓰기 방지
                display_en = 1'b1; // 연산 결과 디스플레이 출력
            end
            
            default: begin 
                write = 1'b0; 
                display_en = 1'b0; 
            end
        endcase
    end

endmodule
