`timescale 1ns / 1ps

module Top_Matrix_Router (
    input clk, input rst, input write_en,
    input [1:0] sel_mode,
    
    // Matrix A
    input [7:0] A11, A12, A13, A14,
    input [7:0] A21, A22, A23, A24,
    input [7:0] A31, A32, A33, A34,
    input [7:0] A41, A42, A43, A44,
    
    // Matrix F
    input [7:0] F11, F12, F13,
    input [7:0] F21, F22, F23,
    input [7:0] F31, F32, F33,
    
    // 연산 모듈 출력
    output reg [7:0] A1_out, A2_out, A3_out,
    output reg [7:0] F1_out, F2_out, F3_out,
    output reg rst_PE, rst_SYS_3x3, rst_SYS_2x2,
    output reg [7:0] nextstate123 // 디버깅용 현재 상태
);

    // Register Bank 연결 와이어 선언
    wire [7:0] rA11, rA12, rA13, rA14, rA21, rA22, rA23, rA24, rA31, rA32, rA33, rA34, rA41, rA42, rA43, rA44;
    wire [7:0] rF11, rF12, rF13, rF21, rF22, rF23, rF31, rF32, rF33;

    // FSM 인스턴스화
    Register_Bank u_Reg (
        .clk(clk), .rst(rst), .write_en(write_en),
        .A11(A11), .A12(A12), .A13(A13), .A14(A14), .A21(A21), .A22(A22), .A23(A23), .A24(A24),
        .A31(A31), .A32(A32), .A33(A33), .A34(A34), .A41(A41), .A42(A42), .A43(A43), .A44(A44),
        .F11(F11), .F12(F12), .F13(F13), .F21(F21), .F22(F22), .F23(F23), .F31(F31), .F32(F32), .F33(F33),
        .outA11(rA11), .outA12(rA12), .outA13(rA13), .outA14(rA14), .outA21(rA21), .outA22(rA22), .outA23(rA23), .outA24(rA24),
        .outA31(rA31), .outA32(rA32), .outA33(rA33), .outA34(rA34), .outA41(rA41), .outA42(rA42), .outA43(rA43), .outA44(rA44),
        .outF11(rF11), .outF12(rF12), .outF13(rF13), .outF21(rF21), .outF22(rF22), .outF23(rF23), .outF31(rF31), .outF32(rF32), .outF33(rF33)
    );

    // 각 모드별 와이어 선언
    wire pe_rst; wire [7:0] pe_A1, pe_F1, pe_state;
    wire sys3_rst; wire [7:0] sys3_A1, sys3_A2, sys3_A3, sys3_state;
    wire sys2_rst; wire [7:0] sys2_A1, sys2_A2, sys2_F1, sys2_F2, sys2_state;

    FSM_Single_PE u_PE (
        .clk(clk), .rst(rst), .enable(sel_mode == 2'b00),
        .outA11(rA11), .outA12(rA12), .outA13(rA13), .outA14(rA14), .outA21(rA21), .outA22(rA22), .outA23(rA23), .outA24(rA24),
        .outA31(rA31), .outA32(rA32), .outA33(rA33), .outA34(rA34), .outA41(rA41), .outA42(rA42), .outA43(rA43), .outA44(rA44),
        .outF11(rF11), .outF12(rF12), .outF13(rF13), .outF21(rF21), .outF22(rF22), .outF23(rF23), .outF31(rF31), .outF32(rF32), .outF33(rF33),
        .rst_PE(pe_rst), .A1_out(pe_A1), .F1_out(pe_F1), .current_state(pe_state)
    );

    FSM_Sys_3x3 u_Sys3 (
        .clk(clk), .rst(rst), .enable(sel_mode == 2'b01),
        .outA11(rA11), .outA12(rA12), .outA13(rA13), .outA14(rA14), .outA21(rA21), .outA22(rA22), .outA23(rA23), .outA24(rA24),
        .outA31(rA31), .outA32(rA32), .outA33(rA33), .outA34(rA34), .outA41(rA41), .outA42(rA42), .outA43(rA43), .outA44(rA44),
        .rst_SYS_3x3(sys3_rst), .A1_out(sys3_A1), .A2_out(sys3_A2), .A3_out(sys3_A3), .current_state(sys3_state)
    );

    FSM_Sys_2x2 u_Sys2 (
        .clk(clk), .rst(rst), .enable(sel_mode == 2'b10),
        .outA11(rA11), .outA12(rA12), .outA13(rA13), .outA14(rA14), .outA21(rA21), .outA22(rA22), .outA23(rA23), .outA24(rA24),
        .outA31(rA31), .outA32(rA32), .outA33(rA33), .outA34(rA34), .outA41(rA41), .outA42(rA42), .outA43(rA43), .outA44(rA44),
        .outF11(rF11), .outF12(rF12), .outF13(rF13), .outF21(rF21), .outF22(rF22), .outF23(rF23), .outF31(rF31), .outF32(rF32), .outF33(rF33),
        .rst_SYS_2x2(sys2_rst), .A1_out(sys2_A1), .A2_out(sys2_A2), .F1_out(sys2_F1), .F2_out(sys2_F2), .current_state(sys2_state)
    );

    // 출력 다중화 (MUX)
    always @(*) begin
        // 기본값 세팅
        A1_out = 8'b0; A2_out = 8'b0; A3_out = 8'b0;
        F1_out = 8'b0; F2_out = 8'b0; F3_out = 8'b0;
        rst_PE = 1'b1; rst_SYS_3x3 = 1'b1; rst_SYS_2x2 = 1'b1;
        nextstate123 = 8'b0;

        case (sel_mode)
            2'b00: begin // Single PE
                A1_out = pe_A1; F1_out = pe_F1; rst_PE = pe_rst; nextstate123 = pe_state;
            end
            2'b01: begin // 3x3 SYS
                A1_out = sys3_A1; A2_out = sys3_A2; A3_out = sys3_A3; rst_SYS_3x3 = sys3_rst; nextstate123 = sys3_state;
            end
            2'b10: begin // 2x2 SYS
                A1_out = sys2_A1; A2_out = sys2_A2; F1_out = sys2_F1; F2_out = sys2_F2; rst_SYS_2x2 = sys2_rst; nextstate123 = sys2_state;
            end
        endcase
    end
endmodule
