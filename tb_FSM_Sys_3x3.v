`timescale 1ns / 1ps

module tb_FSM_Sys_3x3();

    reg clk;
    reg rst;
    reg enable;
    
    reg [7:0] outA11, outA12, outA13, outA14, outA21, outA22, outA23, outA24;
    reg [7:0] outA31, outA32, outA33, outA34, outA41, outA42, outA43, outA44;
    
    wire rst_SYS_3x3;
    wire [7:0] A1_out, A2_out, A3_out, current_state;

    FSM_Sys_3x3 uut (
        .clk(clk), .rst(rst), .enable(enable),
        .outA11(outA11), .outA12(outA12), .outA13(outA13), .outA14(outA14),
        .outA21(outA21), .outA22(outA22), .outA23(outA23), .outA24(outA24),
        .outA31(outA31), .outA32(outA32), .outA33(outA33), .outA34(outA34),
        .outA41(outA41), .outA42(outA42), .outA43(outA43), .outA44(outA44),
        .rst_SYS_3x3(rst_SYS_3x3), .A1_out(A1_out), .A2_out(A2_out), .A3_out(A3_out),
        .current_state(current_state)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        outA11=1; outA12=2; outA13=3; outA14=4; outA21=5; outA22=6; outA23=7; outA24=8;
        outA31=9; outA32=10; outA33=11; outA34=12; outA41=13; outA42=14; outA43=15; outA44=16;

        rst = 1'b1; enable = 1'b0;
        
        #50;
        rst = 1'b0;
        enable = 1'b1;
        
        // 3x3 모드 상태 13개가 순회할 때까지 대기
        #350;
        
        $display("[SUCCESS] 3x3 SYS FSM Simulation Finished.");
        $stop;
    end
endmodule
