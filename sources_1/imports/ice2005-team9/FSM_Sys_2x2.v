`timescale 1ns / 1ps

module FSM_Sys_2x2 (
    input clk,
    input rst,
    input enable,
    
    input [7:0] outA11, outA12, outA13, outA14,
    input [7:0] outA21, outA22, outA23, outA24,
    input [7:0] outA31, outA32, outA33, outA34,
    input [7:0] outA41, outA42, outA43, outA44,
    input [7:0] outF11, outF12, outF13,
    input [7:0] outF21, outF22, outF23,
    input [7:0] outF31, outF32, outF33,
    
    output reg rst_SYS_2x2,
    output reg [7:0] A1_out, A2_out,
    output reg [7:0] F1_out, F2_out,
    output reg [7:0] current_state
);

    parameter INITIAL = 0;
    parameter SYS_2x2_1 = 58, SYS_2x2_2 = 59, SYS_2x2_3 = 60, SYS_2x2_4 = 61, 
              SYS_2x2_5 = 62, SYS_2x2_6 = 63, SYS_2x2_7 = 64, SYS_2x2_8 = 65,
              SYS_2x2_9 = 66, SYS_2x2_10 = 67, SYS_2x2_11 = 68, SYS_2x2_12 = 69,
              SYS_2x2_13 = 70, SYS_2x2_Wait = 71, SYS_2x2_RST = 72;

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
            INITIAL: if (enable) nextstate = SYS_2x2_1;
            SYS_2x2_1 : nextstate = SYS_2x2_2; SYS_2x2_2 : nextstate = SYS_2x2_3; SYS_2x2_3 : nextstate = SYS_2x2_4;
            SYS_2x2_4 : nextstate = SYS_2x2_5; SYS_2x2_5 : nextstate = SYS_2x2_6; SYS_2x2_6 : nextstate = SYS_2x2_7;
            SYS_2x2_7 : nextstate = SYS_2x2_8; SYS_2x2_8 : nextstate = SYS_2x2_9; SYS_2x2_9 : nextstate = SYS_2x2_10;
            SYS_2x2_10 : nextstate = SYS_2x2_11; SYS_2x2_11 : nextstate = SYS_2x2_12; SYS_2x2_12 : nextstate = SYS_2x2_13;
            SYS_2x2_13 : nextstate = SYS_2x2_Wait; SYS_2x2_Wait : nextstate = SYS_2x2_RST; SYS_2x2_RST : nextstate = INITIAL;
            default: nextstate = INITIAL;
        endcase
    end

    always @(*) begin
        rst_SYS_2x2 = 1'b1; A1_out = 8'b0; A2_out = 8'b0; F1_out = 8'b0; F2_out = 8'b0;
        
        case (state)
            SYS_2x2_1 : begin rst_SYS_2x2 = 1'b0; A1_out = outA33; A2_out = outA44; F1_out = outF11; F2_out = outF11; end
            SYS_2x2_2 : begin rst_SYS_2x2 = 1'b0; A1_out = outA32; A2_out = outA43; F1_out = outF12; F2_out = outF12; end
            SYS_2x2_3 : begin rst_SYS_2x2 = 1'b0; A1_out = outA24; A2_out = outA42; F2_out = outF13; end
            SYS_2x2_4 : begin rst_SYS_2x2 = 1'b0; A1_out = outA23; A2_out = outA34; F1_out = outF21; F2_out = outF21; end
            SYS_2x2_5 : begin rst_SYS_2x2 = 1'b0; A1_out = outA22; A2_out = outA33; F1_out = outF22; F2_out = outF22; end  
            SYS_2x2_6 : begin rst_SYS_2x2 = 1'b0; A1_out = outA14; A2_out = outA32; F2_out = outF23; end
            SYS_2x2_7 : begin rst_SYS_2x2 = 1'b0; A1_out = outA13; A2_out = outA24; F1_out = outF31; F2_out = outF31; end
            SYS_2x2_8 : begin rst_SYS_2x2 = 1'b0; A1_out = outA12; A2_out = outA23; F1_out = outF32; F2_out = outF32; end
            SYS_2x2_9 : begin rst_SYS_2x2 = 1'b0; A1_out = outA34; A2_out = outA22; F2_out = outF33; end
            SYS_2x2_10: begin rst_SYS_2x2 = 1'b0; A1_out = outA11; F1_out = outF33; F2_out = outF11; end
            SYS_2x2_11: begin rst_SYS_2x2 = 1'b0; A1_out = outA21; A2_out = outA21; F1_out = outF23; end
            SYS_2x2_12: begin rst_SYS_2x2 = 1'b0; A1_out = outA31; A2_out = outA31; F1_out = outF13; end
            SYS_2x2_13: begin rst_SYS_2x2 = 1'b0; A1_out = outA32; A2_out = outA41; end
            SYS_2x2_Wait : begin rst_SYS_2x2 = 1'b0; end
            SYS_2x2_RST : begin rst_SYS_2x2 = 1'b1; end
        endcase
    end
endmodule
