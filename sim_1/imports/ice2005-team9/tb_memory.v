`timescale 1ns / 1ps

module tb_memory();

    reg clk, rst, start;
    reg [1:0] sel_mode; 
    
    // Matrix Inputs
    reg [7:0] A11, A12, A13, A14, A21, A22, A23, A24;
    reg [7:0] A31, A32, A33, A34, A41, A42, A43, A44;
    reg [7:0] F11, F12, F13, F21, F22, F23, F31, F32, F33;

    // Output wires
    wire write, display_en; 
    wire [7:0] A1_out, A2_out, A3_out, F1_out, F2_out, F3_out;
    wire rst_PE, rst_SYS_3x3, rst_SYS_2x2;
    wire [7:0] nextstate;

    // 1. 컨트롤러 인스턴스화
    controller u_ctrl (
        .clk(clk), .rst(rst), .start(start),
        .write(write), .display_en(display_en)
    );

    // 2. 메모리(Wrapper) 인스턴스화
    memory u_mem (
        .clk(clk), .rst(rst), .write(write), .sel_mode(sel_mode),
        .A11(A11), .A12(A12), .A13(A13), .A14(A14), .A21(A21), .A22(A22), .A23(A23), .A24(A24),
        .A31(A31), .A32(A32), .A33(A33), .A34(A34), .A41(A41), .A42(A42), .A43(A43), .A44(A44),
        .F11(F11), .F12(F12), .F13(F13), .F21(F21), .F22(F22), .F23(F23), .F31(F31), .F32(F32), .F33(F33),
        .A1_out(A1_out), .A2_out(A2_out), .A3_out(A3_out),
        .F1_out(F1_out), .F2_out(F2_out), .F3_out(F3_out),
        .rst_PE(rst_PE), .rst_SYS_3x3(rst_SYS_3x3), .rst_SYS_2x2(rst_SYS_2x2),
        .nextstate123(nextstate)
    );

    // 클럭 생성 (주기 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 데이터 세팅
    initial begin
        A11=8'd1;  A12=8'd2;  A13=8'd3;  A14=8'd4;
        A21=8'd5;  A22=8'd6;  A23=8'd7;  A24=8'd8;
        A31=8'd9;  A32=8'd10; A33=8'd11; A34=8'd12;
        A41=8'd13; A42=8'd14; A43=8'd15; A44=8'd16;
        
        F11=8'd1;  F12=8'd2;  F13=8'd3;
        F21=8'd4;  F22=8'd5;  F23=8'd6;
        F31=8'd7;  F32=8'd8;  F33=8'd9;
    end

    // 테스트 시나리오
    initial begin
        // 초기 리셋
        rst = 1'b1; start = 1'b0; sel_mode = 2'b11; 
        
        // Single PE 모드 진입 (컨트롤러 가동)
        #100 
        rst = 1'b0; start = 1'b1; sel_mode = 2'b00; 
        
        // 연산 시간 대기
        #960 
        
        // 3x3 Systolic Array 모드 진입 (재시작)
        rst = 1'b1; start = 1'b0;
        #20;
        rst = 1'b0; start = 1'b1; sel_mode = 2'b01; 
        
        #780 
        
        // 2x2 Systolic Array 모드 진입 (재시작)
        rst = 1'b1; start = 1'b0;
        #20;
        rst = 1'b0; start = 1'b1; sel_mode = 2'b10; 
        
        #700 
        $stop; 
    end
endmodule
