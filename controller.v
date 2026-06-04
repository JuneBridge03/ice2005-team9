module controller (
    input clk,          
    input rst,          
    input start,          
    output reg write,     
    output reg display_en,
    output reg calc_rst    //  [추가] 연산기를 꽉 잡고 있을 전용 리셋 신호
);

    // ... (상태 머신 로직은 이전 답변과 동일하게 유지) ...

    always @(*) begin
        // 기본값
        write = 1'b0;
        display_en = 1'b0;
        calc_rst = 1'b1; // 기본적으로 연산기를 리셋 상태로 꽉 묶어둠

        case(current_state)
            IDLE: begin 
                calc_rst = 1'b1; // 대기 중에는 연산 금지
            end
            
            WAIT_PE: begin 
                if (wait_cnt == 5'd0) write = 1'b1; // 메모리 켬
                else                  write = 1'b0;
                
                calc_rst = 1'b0; //  데이터가 나가는 순간 연산기 리셋 해제! 연산 시작!
                display_en = 1'b0; 
            end
            
            COMPUTE: begin 
                calc_rst = 1'b0; // 연산 끝났거나 진행 중일 때 계속 해제 상태 유지
                display_en = 1'b1; 
            end
        endcase
    end
endmodule
