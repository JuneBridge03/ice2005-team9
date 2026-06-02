
module controller (
    input clk,          // 클럭 신호 
    input rst,          // 리셋 신호
    output reg write,   // 메모리 입력(Write) 활성화 신호 
    output reg display_en // 디스플레이 활성화 신호 
);

    // Clock 신호의 상승 에지(posedge)마다 동작 
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            // Reset 신호가 1일 경우 초기화를 수행 
            // write 기능과 display 기능 모두 실행되지 않도록 0으로 설정            write <= 1'b0;
            display_en <= 1'b0;
        end
        else begin
            // Reset이 1이 아닐 경우 정상적인 동작 수행 
            // 메모리에 값을 입력할 수 있도록 write에 1을 인가 
            // 계산 결과를 출력하도록 display enable 신호 인가 
            write <= 1'b1;
            display_en <= 1'b1;
        end
    end
    
endmodule
