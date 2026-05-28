`timescale 1ns / 1ps

module tb_Top_Matrix_Router();

    reg clk;             
    reg rst;             
    reg write;           
    reg [1:0] sel_mode;  
    
    reg [7:0] A11, A12, A13, A14;
    reg [7:0] A21, A22, A23, A24;
    reg [7:0] A31, A32, A33, A34;
    reg [7:0] A41, A42, A43, A44;
    
    reg [7:0] F11, F12, F13;
    reg [7:0] F21, F22, F23;
    reg [7:0] F31, F32, F33;

    wire [7:0] A1_out, A2_out, A3_out;
    wire [7:0] F1_out, F2_out, F3_out;
    wire rst_PE, rst_SYS_3x3, rst_SYS_2x2;
    wire [7:0] nextstate;

    Top_Matrix_Router m3 (
        .clk(clk), .rst(rst), .write_en(write), .sel_mode(sel_mode),
        .A11(A11), .A12(A12), .A13(A13), .A14(A14), .A21(A21), .A22(A22), .A23(A23), .A24(A24),
        .A31(A31), .A32(A32), .A33(A33), .A34(A34), .A41(A41), .A42(A42), .A43(A43), .A44(A44),
        .F11(F11), .F12(F12), .F13(F13), .F21(F21), .F22(F22), .F23(F23), .F31(F31), .F32(F32), .F33(F33),
        .A1_out(A1_out), .A2_out(A2_out), .A3_out(A3_out),
        .F1_out(F1_out), .F2_out(F2_out), .F3_out(F3_out),
        .rst_PE(rst_PE), .rst_SYS_3x3(rst_SYS_3x3), .rst_SYS_2x2(rst_SYS_2x2),
        .nextstate123(nextstate)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 주기 20ns
    end

    initial begin
        A11=8'd1;  A12=8'd2;  A13=8'd3;  A14=8'd4;
        A21=8'd5;  A22=8'd6;  A23=8'd7;  A24=8'd8;
        A31=8'd9;  A32=8'd10; A33=8'd11; A34=8'd12;
        A41=8'd13; A42=8'd14; A43=8'd15; A44=8'd16;
        
        F11=8'd1;  F12=8'd2;  F13=8'd3;
        F21=8'd4;  F22=8'd5;  F23=8'd6;
        F31=8'd7;  F32=8'd8;  F33=8'd9;
    end

    initial begin
        rst = 1'b1; write = 1'b0; sel_mode = 2'b11; 
        
        // 데이터 쓰기 활성화 및 Single PE 모드 진입
        #100 
        rst = 1'b0; 
        write = 1'b1;
        sel_mode = 2'b00; 
        
        // 주의: 메모리 덮어쓰기를 막기 위해, 데이터 저장 후 1클럭(20ns) 뒤에 write를 0으로 내리는 것이 좋습니다.
        #20 write = 1'b0;
        
        // 3x3 Systolic Array 모드 진입
        #940 // (기존 960ns 대기 시간에서 write 제어용 20ns 뺌)
        sel_mode = 2'b01; 
        
        // 2x2 Systolic Array 모드 진입
        #780 
        sel_mode = 2'b10; 
        
        // 종료
        #700 
        $stop; 
    end

endmodule
