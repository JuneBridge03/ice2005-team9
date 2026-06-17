`timescale 1ns / 1ns

module display_driver_tb();
    reg clk;
    reg rst;
    reg [7:0] bin_in;
    
    wire [6:0] seg_led;
    wire [2:0] seg_digit;

    // 2. 테스트할 원본 모듈 인스턴스화
    display_driver_module dut (
        .clk(clk),
        .rst(rst),
        .in(bin_in),
        .seg_led(seg_led),
        .seg_digit(seg_digit)
    );

    // 3. 100MHz 시스템 클럭 생성 (주기: 10ns)
    // 5ns마다 클럭 신호를 반전시킵니다.
    always #5 clk = ~clk;

    // 4. 입력 자극(Stimulus) 인가
    initial begin
        // 초기 상태 설정
        clk = 0;
        rst = 1;
        bin_in = 8'd0;

        // 100ns 대기 후 리셋 해제 (정상 동작 시작)
        #100;
        rst = 0;

        // 테스트 케이스 1: 십진수 123 입력
        bin_in = 8'd123;
        // 설계하신 모듈은 약 3.27ms 마다 자릿수가 바뀝니다 (2^15 클럭).
        // 세 자리가 모두 켜지는 것을 확인하기 위해 1ms (1,000,000ns) 이상의 충분한 시간을 대기합니다.
        #2000000; 

        // 테스트 케이스 2: 십진수 255 입력 (8비트 최대값)
        bin_in = 8'd255;
        #2000000;

        // 테스트 케이스 3: 십진수 9 입력 (백의 자리와 십의 자리는 0이 출력되어야 함)
        bin_in = 8'd9;
        #2000000;

        // 시뮬레이션 종료
        $finish;
    end
endmodule
