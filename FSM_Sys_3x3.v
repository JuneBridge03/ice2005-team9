`timescale 1ns / 1ps

module FSM_Sys_3x3 (
    input clk,
    input rst,
    input enable,
    
    input [7:0] outA11, outA12, outA13, outA14,
    input [7:0] outA21, outA22, outA23, outA24,
    input [7:0] outA31, outA32, outA33, outA34,
    input [7:0] outA41, outA42, outA43, outA44,
    
    output reg rst_SYS_3x3,
    output reg [7:0] A1_out, A2_out, A3_out,
    output reg [7:0] current_state
);

    parameter INITIAL = 0;
    parameter SYS_3x3_1 = 45,  SYS_3x3_2 = 46, SYS_3x3_3 = 47, SYS_3x3_4 = 48, SYS_3x3_5 = 49, SYS_3x3_6 = 50, SYS_3x3_7 = 51, SYS_3x3_8 = 52, SYS_3x3_9 = 53, SYS_3x3_10 = 54, 
              SYS_3x3_11 = 55, SYS_3x3_Wait = 56, SYS_3x3_RST = 57;

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
            INITIAL: if (enable) nextstate = SYS_3x3_1;
            SYS_3x3_1 : nextstate = SYS_3x3_2; SYS_3x3_2 : nextstate = SYS_3x3_3; SYS_3x3_3 : nextstate = SYS_3x3_4;
            SYS_3x3_4 : nextstate = SYS_3x3_5; SYS_3x3_5 : nextstate = SYS_3x3_6; SYS_3x3_6 : nextstate = SYS_3x3_7;
            SYS_3x3_7 : nextstate = SYS_3x3_8; SYS_3x3_8 : nextstate = SYS_3x3_9; SYS_3x3_9 : nextstate = SYS_3x3_10;
            SYS_3x3_10 : nextstate = SYS_3x3_11; SYS_3x3_11 : nextstate = SYS_3x3_Wait; SYS_3x3_Wait : nextstate = SYS_3x3_RST;
            SYS_3x3_RST : nextstate = INITIAL;
            default: nextstate = INITIAL;
        endcase
    end

    always @(*) begin
        rst_SYS_3x3 = 1'b1; A1_out = 8'b0; A2_out = 8'b0; A3_out = 8'b0;
        
        case (state)
            SYS_3x3_1 : begin rst_SYS_3x3 = 1'b0; A1_out = outA14; end  
            SYS_3x3_2 : begin rst_SYS_3x3 = 1'b0; A1_out = outA13; A2_out = outA24; end
            SYS_3x3_3 : begin rst_SYS_3x3 = 1'b0; A1_out = outA12; A2_out = outA23; A3_out = outA34; end  
            SYS_3x3_4 : begin rst_SYS_3x3 = 1'b0; A1_out = outA11; A2_out = outA22; A3_out = outA33; end  
            SYS_3x3_5 : begin rst_SYS_3x3 = 1'b0; A1_out = outA24; A2_out = outA21; A3_out = outA32; end // 원본 코드 로직 유지
            SYS_3x3_6 : begin rst_SYS_3x3 = 1'b0; A1_out = outA23; A2_out = outA34; A3_out = outA31; end
            SYS_3x3_7 : begin rst_SYS_3x3 = 1'b0; A1_out = outA22; A2_out = outA33; A3_out = outA44; end
            SYS_3x3_8 : begin rst_SYS_3x3 = 1'b0; A1_out = outA21; A2_out = outA32; A3_out = outA43; end
            SYS_3x3_9 : begin rst_SYS_3x3 = 1'b0; A2_out = outA31; A3_out = outA42; end
            SYS_3x3_10: begin rst_SYS_3x3 = 1'b0; A3_out = outA41; end
            SYS_3x3_11: begin rst_SYS_3x3 = 1'b0; end        
            SYS_3x3_Wait : begin rst_SYS_3x3 = 1'b0; end
            SYS_3x3_RST : begin rst_SYS_3x3 = 1'b1; end
        endcase
    end
endmodule
