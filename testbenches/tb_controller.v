// 이 테스트벤치는 메모리 없이 오직 controller.v 하나만 불러와서, start 신호가 들어왔을 때 상태
// (State)가 잘 변하는지, write와 display_en 신호가 타이밍에 맞게 나오는지 파형으로 확인하기 위한 코드.
`timescale 1ns / 1ps

module tb_controller();

    // 1. 입력 제어용 reg 선언
    reg clk;
    reg rst;
    reg start;

    // 2. 출력 관측용 wire 선언
    wire write;
    wire display_en;

    // 3. 검증할 모듈(controller) 인스턴스화
    controller uut (
        .clk(clk), 
        .rst(rst), 
        .start(start),
        .write(write), 
        .display_en(display_en)
    );

    // 4. 클럭 생성 (20ns 주기)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 5. 테스트 시나리오
    initial begin
        // [초기 상태] 리셋 활성화
        rst = 1'b1;
        start = 1'b0;
        
        #50; // 50ns 대기하여 안정화
        
        // [테스트 1] 리셋 해제 및 연산 시작
        // start 신호를 주면 다음 클럭에서 write가 딱 1번(20ns)만 1로 켜져야 함
        rst = 1'b0;
        start = 1'b1;
        
        #20; 
        // start 신호는 계속 1로 유지되어도, 내부 상태머신에 의해 
        // write는 0으로 떨어지고 display_en이 1로 올라가는지 확인
        
        #60;
        
        // [테스트 2] 동작 중 강제 리셋 확인
        // 연산 도중에 리셋이 들어오면 모든 신호가 0으로 즉시 초기화되는지 확인
        rst = 1'b1;
        
        #40;
        
        $display("[SUCCESS] Controller Test Simulation Finished.");
        $stop;
    end

endmodule
