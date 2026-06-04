`timescale 1ns / 1ps

module FSM_Single_PE (
    input clk,
    input rst,
    input enable, 
    
    // Register Bank 연결
    input [7:0] outA11, outA12, outA13, outA14,
    input [7:0] outA21, outA22, outA23, outA24,
    input [7:0] outA31, outA32, outA33, outA34,
    input [7:0] outA41, outA42, outA43, outA44,
    input [7:0] outF11, outF12, outF13,
    input [7:0] outF21, outF22, outF23,
    input [7:0] outF31, outF32, outF33,
    
    output reg rst_PE,
    output reg [7:0] A1_out,
    output reg [7:0] F1_out,
    output reg [7:0] current_state // 관측용
);

    parameter INITIAL = 0;               
    parameter C11_PE_1 = 1, C11_PE_2 = 2, C11_PE_3 = 3, C11_PE_4 = 4, C11_PE_5 = 5, C11_PE_6 = 6, C11_PE_7 = 7, C11_PE_8 = 8, C11_PE_9 = 9, C11_PE_Wait = 10, C11_PE_RST = 11;
    parameter C12_PE_1 = 12, C12_PE_2 = 13, C12_PE_3 = 14, C12_PE_4 = 15, C12_PE_5 = 16, C12_PE_6 = 17, C12_PE_7 = 18, C12_PE_8 = 19, C12_PE_9 = 20, C12_PE_Wait = 21, C12_PE_RST = 22;
    parameter C21_PE_1 = 23, C21_PE_2 = 24, C21_PE_3 = 25, C21_PE_4 = 26, C21_PE_5 = 27, C21_PE_6 = 28, C21_PE_7 = 29, C21_PE_8 = 30, C21_PE_9 = 31, C21_PE_Wait = 32, C21_PE_RST = 33;
    parameter C22_PE_1 = 34, C22_PE_2 = 35, C22_PE_3 = 36, C22_PE_4 = 37, C22_PE_5 = 38, C22_PE_6 = 39, C22_PE_7 = 40, C22_PE_8 = 41, C22_PE_9 = 42, C22_PE_Wait = 43, C22_PE_RST = 44;

    reg [7:0] state, nextstate;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= INITIAL;
        else if (enable) state <= nextstate;
        else state <= INITIAL;
    end

    always @(*) begin
        nextstate = state; 
        current_state = state;
        
        case(state)
            INITIAL: if (enable) nextstate = C11_PE_1;
            
            C11_PE_1 : nextstate = C11_PE_2; C11_PE_2 : nextstate = C11_PE_3; C11_PE_3 : nextstate = C11_PE_4;
            C11_PE_4 : nextstate = C11_PE_5; C11_PE_5 : nextstate = C11_PE_6; C11_PE_6 : nextstate = C11_PE_7;
            C11_PE_7 : nextstate = C11_PE_8; C11_PE_8 : nextstate = C11_PE_9; C11_PE_9 : nextstate = C11_PE_Wait;
            C11_PE_Wait : nextstate = C11_PE_RST; C11_PE_RST : nextstate = C12_PE_1;
            
            C12_PE_1 : nextstate = C12_PE_2; C12_PE_2 : nextstate = C12_PE_3; C12_PE_3 : nextstate = C12_PE_4;
            C12_PE_4 : nextstate = C12_PE_5; C12_PE_5 : nextstate = C12_PE_6; C12_PE_6 : nextstate = C12_PE_7;
            C12_PE_7 : nextstate = C12_PE_8; C12_PE_8 : nextstate = C12_PE_9; C12_PE_9 : nextstate = C12_PE_Wait;
            C12_PE_Wait : nextstate = C12_PE_RST; C12_PE_RST : nextstate = C21_PE_1;
            
            C21_PE_1 : nextstate = C21_PE_2; C21_PE_2 : nextstate = C21_PE_3; C21_PE_3 : nextstate = C21_PE_4;
            C21_PE_4 : nextstate = C21_PE_5; C21_PE_5 : nextstate = C21_PE_6; C21_PE_6 : nextstate = C21_PE_7;
            C21_PE_7 : nextstate = C21_PE_8; C21_PE_8 : nextstate = C21_PE_9; C21_PE_9 : nextstate = C21_PE_Wait;
            C21_PE_Wait : nextstate = C21_PE_RST; C21_PE_RST : nextstate = C22_PE_1;
            
            C22_PE_1 : nextstate = C22_PE_2; C22_PE_2 : nextstate = C22_PE_3; C22_PE_3 : nextstate = C22_PE_4;
            C22_PE_4 : nextstate = C22_PE_5; C22_PE_5 : nextstate = C22_PE_6; C22_PE_6 : nextstate = C22_PE_7;
            C22_PE_7 : nextstate = C22_PE_8; C22_PE_8 : nextstate = C22_PE_9; C22_PE_9 : nextstate = C22_PE_Wait;
            C22_PE_Wait : nextstate = C22_PE_RST; C22_PE_RST : nextstate = INITIAL; // 한 사이클 종료
            default: nextstate = INITIAL;
        endcase
    end

    always @(*) begin
        rst_PE = 1'b1; A1_out = 8'b0; F1_out = 8'b0;
        
        case (state)
            C11_PE_1 : begin rst_PE = 1'b0; A1_out = outA11; F1_out = outF33; end
            C11_PE_2 : begin rst_PE = 1'b0; A1_out = outA12; F1_out = outF32; end
            C11_PE_3 : begin rst_PE = 1'b0; A1_out = outA13; F1_out = outF31; end
            C11_PE_4 : begin rst_PE = 1'b0; A1_out = outA21; F1_out = outF23; end
            C11_PE_5 : begin rst_PE = 1'b0; A1_out = outA22; F1_out = outF22; end
            C11_PE_6 : begin rst_PE = 1'b0; A1_out = outA23; F1_out = outF21; end
            C11_PE_7 : begin rst_PE = 1'b0; A1_out = outA31; F1_out = outF13; end
            C11_PE_8 : begin rst_PE = 1'b0; A1_out = outA32; F1_out = outF12; end
            C11_PE_9 : begin rst_PE = 1'b0; A1_out = outA33; F1_out = outF11; end
            C11_PE_Wait : begin rst_PE = 1'b0; end
            C11_PE_RST : begin rst_PE = 1'b1; end 
            
            C12_PE_1 : begin rst_PE = 1'b0; A1_out = outA12; F1_out = outF33; end
            C12_PE_2 : begin rst_PE = 1'b0; A1_out = outA13; F1_out = outF32; end
            C12_PE_3 : begin rst_PE = 1'b0; A1_out = outA14; F1_out = outF31; end
            C12_PE_4 : begin rst_PE = 1'b0; A1_out = outA22; F1_out = outF23; end
            C12_PE_5 : begin rst_PE = 1'b0; A1_out = outA23; F1_out = outF22; end
            C12_PE_6 : begin rst_PE = 1'b0; A1_out = outA24; F1_out = outF21; end
            C12_PE_7 : begin rst_PE = 1'b0; A1_out = outA32; F1_out = outF13; end
            C12_PE_8 : begin rst_PE = 1'b0; A1_out = outA33; F1_out = outF12; end
            C12_PE_9 : begin rst_PE = 1'b0; A1_out = outA34; F1_out = outF11; end
            C12_PE_Wait : begin rst_PE = 1'b0; end
            C12_PE_RST : begin rst_PE = 1'b1; end
            
            C21_PE_1 : begin rst_PE = 1'b0; A1_out = outA21; F1_out = outF33; end
            C21_PE_2 : begin rst_PE = 1'b0; A1_out = outA22; F1_out = outF32; end
            C21_PE_3 : begin rst_PE = 1'b0; A1_out = outA23; F1_out = outF31; end
            C21_PE_4 : begin rst_PE = 1'b0; A1_out = outA31; F1_out = outF23; end
            C21_PE_5 : begin rst_PE = 1'b0; A1_out = outA32; F1_out = outF22; end
            C21_PE_6 : begin rst_PE = 1'b0; A1_out = outA33; F1_out = outF21; end
            C21_PE_7 : begin rst_PE = 1'b0; A1_out = outA41; F1_out = outF13; end
            C21_PE_8 : begin rst_PE = 1'b0; A1_out = outA42; F1_out = outF12; end
            C21_PE_9 : begin rst_PE = 1'b0; A1_out = outA43; F1_out = outF11; end
            C21_PE_Wait : begin rst_PE = 1'b0; end
            C21_PE_RST : begin rst_PE = 1'b1; end
            
            C22_PE_1 : begin rst_PE = 1'b0; A1_out = outA22; F1_out = outF33; end
            C22_PE_2 : begin rst_PE = 1'b0; A1_out = outA23; F1_out = outF32; end
            C22_PE_3 : begin rst_PE = 1'b0; A1_out = outA24; F1_out = outF31; end
            C22_PE_4 : begin rst_PE = 1'b0; A1_out = outA32; F1_out = outF23; end
            C22_PE_5 : begin rst_PE = 1'b0; A1_out = outA33; F1_out = outF22; end
            C22_PE_6 : begin rst_PE = 1'b0; A1_out = outA34; F1_out = outF21; end
            C22_PE_7 : begin rst_PE = 1'b0; A1_out = outA42; F1_out = outF13; end
            C22_PE_8 : begin rst_PE = 1'b0; A1_out = outA43; F1_out = outF12; end
            C22_PE_9 : begin rst_PE = 1'b0; A1_out = outA44; F1_out = outF11; end
            C22_PE_Wait : begin rst_PE = 1'b0; end
            C22_PE_RST : begin rst_PE = 1'b1; end
        endcase
    end
endmodule
