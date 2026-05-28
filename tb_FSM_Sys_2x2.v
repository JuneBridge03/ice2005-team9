`timescale 1ns / 1ps

module tb_FSM_Sys_2x2();

    reg clk;
    reg rst;
    reg enable;
    
    reg [7:0] outA11, outA12, outA13, outA14, outA21, outA22, outA23, outA24;
    reg [7:0] outA31, outA32, outA33, outA34, outA41, outA42, outA43, outA44;
    reg [7:0] outF11, outF12, outF13, outF21, outF22, outF23, outF31, outF32, outF33;
    
    wire rst_SYS_2x2;
    wire [7:0] A1_out, A2_out, F1_out, F2_out, current_state;

    FSM_Sys_2x2 uut (
        .clk(clk), .rst(rst), .enable(enable),
        .outA11(outA11), .outA12(outA12), .outA13(outA13), .outA14(outA14),
        .outA21(outA21), .outA22(outA22), .outA23(outA23), .outA24(outA24),
        .outA31(outA31), .outA32(outA32), .outA33(outA33), .outA34(outA34),
        .outA41(outA41), .outA42(outA42), .outA43(outA43), .outA44(outA44),
        .outF11(outF11), .outF12(outF12), .outF13(outF13),
        .outF21(outF21), .outF22(outF22), .outF23(outF23),
        .outF31(outF31), .outF32(outF32), .outF33(outF33),
        .rst_SYS_2x2(rst_SYS_2x2), .A1_out(A1_out), .A2_out(A2_out), .F1_out(F1_out), .F2_out(F2_out),
        .current_state(current_state)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        outA11=1; outA12=2; outA13=3; outA14=4; outA21=5; outA22=6; outA23=7; outA24=8;
        outA31=9; outA32=10; outA33=11; outA34=12; outA41=13; outA42=14; outA43=15; outA44=16;
        outF11=1; outF12=2; outF13=3; outF21=4; outF22=5; outF23=6; outF31=7; outF32=8; outF33=9;

        rst = 1'b1; enable = 1'b0;
        
        #50;
        rst = 1'b0;
        enable = 1'b1;
        
        // 2x2 모드 상태 15개가 순회할 때까지 대기
        #400;
        
        $display("[SUCCESS] 2x2 SYS FSM Simulation Finished.");
        $stop;
    end
endmodule
