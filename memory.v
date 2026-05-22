`timescale 1ns / 1ps

module memory (
    input clk, input rst, input write,

    // Matrix A Inputs (4x4)
    input [7:0] A11, A12, A13, A14,
    input [7:0] A21, A22, A23, A24,
    input [7:0] A31, A32, A33, A34,
    input [7:0] A41, A42, A43, A44,
    
    // Filter Matrix F Inputs (3x3)
    input [7:0] F11, F12, F13,
    input [7:0] F21, F22, F23,
    input [7:0] F31, F32, F33,

    // ?? ?? ?? (00: Single PE, 01: 3x3 SYS, 10: 2x2 SYS)
    input [1:0] sel_mode,
  
    // ?? ??? ???? ??? ????
    output [7:0] A1_out, A2_out, A3_out, 
    output [7:0] F1_out, F2_out, F3_out,
    
    // ?? ?? ??? ?? ?? ??
    output rst_PE,
    output rst_SYS_3x3,
    output rst_SYS_2x2, 
    
    // ??? ? ????? ??? ?? ??
    output [7:0] nextstate123
);

// =========================================================================
// 1. ??(State) ???? ??
// =========================================================================
parameter INITIAL = 0;               

parameter  start1 = 100, start2=101, start3=102,  
           // Single PE ?? ?? (C11 ~ C22 ?? ??)
           C11_PE_1 = 1, C11_PE_2 = 2, C11_PE_3 = 3, C11_PE_4 = 4, C11_PE_5 = 5, C11_PE_6 = 6, C11_PE_7 = 7, C11_PE_8 = 8, C11_PE_9 = 9, C11_PE_Wait = 10, C11_PE_RST = 11,
           C12_PE_1 = 12, C12_PE_2 = 13, C12_PE_3 = 14, C12_PE_4 = 15, C12_PE_5 = 16, C12_PE_6 = 17, C12_PE_7 = 18, C12_PE_8 = 19, C12_PE_9 = 20, C12_PE_Wait = 21, C12_PE_RST = 22,
           C21_PE_1 = 23, C21_PE_2 = 24, C21_PE_3 = 25, C21_PE_4 = 26, C21_PE_5 = 27, C21_PE_6 = 28, C21_PE_7 = 29, C21_PE_8 = 30, C21_PE_9 = 31, C21_PE_Wait = 32, C21_PE_RST = 33,
           C22_PE_1 = 34, C22_PE_2 = 35, C22_PE_3 = 36, C22_PE_4 = 37, C22_PE_5 = 38, C22_PE_6 = 39, C22_PE_7 = 40, C22_PE_8 = 41, C22_PE_9 = 42, C22_PE_Wait = 43, C22_PE_RST = 44,
          
           // 3x3 Systolic Array ?? ??
           SYS_3x3_1 = 45,  SYS_3x3_2 = 46, SYS_3x3_3 = 47, SYS_3x3_4 = 48, SYS_3x3_5 = 49, SYS_3x3_6 = 50, SYS_3x3_7 = 51, SYS_3x3_8 = 52, SYS_3x3_9 = 53, SYS_3x3_10 = 54, 
           SYS_3x3_11 = 55, SYS_3x3_Wait = 56, SYS_3x3_RST = 57,
          
           // 2x2 Systolic Array ?? ??
           SYS_2x2_1 = 58, SYS_2x2_2 = 59, SYS_2x2_3 = 60, SYS_2x2_4 = 61, 
           SYS_2x2_5 = 62, SYS_2x2_6 = 63, SYS_2x2_7 = 64, SYS_2x2_8 = 65,
           SYS_2x2_9 = 66, SYS_2x2_10 = 67, SYS_2x2_11 = 68, SYS_2x2_12 = 69,
           SYS_2x2_13 = 70, SYS_2x2_Wait = 71, SYS_2x2_RST = 72;

// =========================================================================
// 2. ?? ?? ? ??(Wire/Reg) ??
// =========================================================================
// ???? ?????? ???? ??? wire
wire [7:0]  outA11, outA12, outA13, outA14,
            outA21, outA22, outA23, outA24,
            outA31, outA32, outA33, outA34,
            outA41, outA42, outA43, outA44,
            outF11, outF12, outF13,
            outF21, outF22, outF23,
            outF31, outF32, outF33;

reg [7:0] state, nextstate; 
reg [1:0] sel_mode_in; // ??? ??? ???? ???? ?? ?? ??
            
// ??? ??? ?? reg
reg [7:0] reg_addr_mem_A1, reg_addr_mem_A2, reg_addr_mem_A3;
reg [7:0] reg_addr_mem_F1, reg_addr_mem_F2, reg_addr_mem_F3;
reg reg_rst_PE, reg_rst_SYS_3x3, reg_rst_SYS_2x2;

// ?? reg ?? ?? ?? ??(output)? ??
assign rst_PE = reg_rst_PE;
assign rst_SYS_3x3 = reg_rst_SYS_3x3;
assign rst_SYS_2x2 = reg_rst_SYS_2x2;
assign A1_out = reg_addr_mem_A1;
assign A2_out = reg_addr_mem_A2;
assign A3_out = reg_addr_mem_A3;
assign F1_out = reg_addr_mem_F1;
assign F2_out = reg_addr_mem_F2;
assign F3_out = reg_addr_mem_F3;
assign nextstate123 = state; // ????? ??? (nextstate? ?? ?? state? ???? ?? ???)

// =========================================================================
// 3. 8-bit Register ??? ?? ?? (? 25?)
// =========================================================================
eight_bit_register_structural_module AA11(.in(A11), .clk(clk), .en(write), .rst(rst), .out(outA11));
eight_bit_register_structural_module AA12(.in(A12), .clk(clk), .en(write), .rst(rst), .out(outA12));
eight_bit_register_structural_module AA13(.in(A13), .clk(clk), .en(write), .rst(rst), .out(outA13));
eight_bit_register_structural_module AA14(.in(A14), .clk(clk), .en(write), .rst(rst), .out(outA14));

eight_bit_register_structural_module AA21(.in(A21), .clk(clk), .en(write), .rst(rst), .out(outA21));
eight_bit_register_structural_module AA22(.in(A22), .clk(clk), .en(write), .rst(rst), .out(outA22));
eight_bit_register_structural_module AA23(.in(A23), .clk(clk), .en(write), .rst(rst), .out(outA23));
eight_bit_register_structural_module AA24(.in(A24), .clk(clk), .en(write), .rst(rst), .out(outA24));

eight_bit_register_structural_module AA31(.in(A31), .clk(clk), .en(write), .rst(rst), .out(outA31));
eight_bit_register_structural_module AA32(.in(A32), .clk(clk), .en(write), .rst(rst), .out(outA32));
eight_bit_register_structural_module AA33(.in(A33), .clk(clk), .en(write), .rst(rst), .out(outA33));
eight_bit_register_structural_module AA34(.in(A34), .clk(clk), .en(write), .rst(rst), .out(outA34));

eight_bit_register_structural_module AA41(.in(A41), .clk(clk), .en(write), .rst(rst), .out(outA41));
eight_bit_register_structural_module AA42(.in(A42), .clk(clk), .en(write), .rst(rst), .out(outA42));
eight_bit_register_structural_module AA43(.in(A43), .clk(clk), .en(write), .rst(rst), .out(outA43));
eight_bit_register_structural_module AA44(.in(A44), .clk(clk), .en(write), .rst(rst), .out(outA44));

eight_bit_register_structural_module FF11(.in(F11), .clk(clk), .en(write), .rst(rst), .out(outF11));
eight_bit_register_structural_module FF12(.in(F12), .clk(clk), .en(write), .rst(rst), .out(outF12));
eight_bit_register_structural_module FF13(.in(F13), .clk(clk), .en(write), .rst(rst), .out(outF13));

eight_bit_register_structural_module FF21(.in(F21), .clk(clk), .en(write), .rst(rst), .out(outF21));
eight_bit_register_structural_module FF22(.in(F22), .clk(clk), .en(write), .rst(rst), .out(outF22));
eight_bit_register_structural_module FF23(.in(F23), .clk(clk), .en(write), .rst(rst), .out(outF23));

eight_bit_register_structural_module FF31(.in(F31), .clk(clk), .en(write), .rst(rst), .out(outF31));
eight_bit_register_structural_module FF32(.in(F32), .clk(clk), .en(write), .rst(rst), .out(outF32));
eight_bit_register_structural_module FF33(.in(F33), .clk(clk), .en(write), .rst(rst), .out(outF33));


// =========================================================================
// 4. ?? ??(FSM) ?? - ???? 3-Always Block ?? ??
// =========================================================================

// [Block 1] ?? ??: ?? ???? ? ?? ??? (?? ??)
always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin
        state <= INITIAL;
        sel_mode_in <= 2'b11;
    end else begin
        state <= nextstate;
        sel_mode_in <= sel_mode; // ?? ??? ??? ?? ???? ??
    end
end

// [Block 2] ?? ??: ?? ??(Next State) ?? ??
always @(*) begin
    // ??(Latch) ??? ?? ??? ??
    nextstate = state; 
    
    case(state)
        INITIAL: begin
            if (sel_mode_in == 2'b00)       nextstate = start1;
            else if (sel_mode_in == 2'b01)  nextstate = start2;
            else if (sel_mode_in == 2'b10)  nextstate = start3;
            else                            nextstate = INITIAL;
        end
        
        start1: nextstate = C11_PE_1;
        start2: nextstate = SYS_3x3_1;
        start3: nextstate = SYS_2x2_1;
        
        // --- Single PE ?? ?? ---
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
        C22_PE_Wait : nextstate = C22_PE_RST; C22_PE_RST : nextstate = INITIAL;
        
        // --- 3x3 Systolic Array ?? ?? ---
        SYS_3x3_1 : nextstate = SYS_3x3_2; SYS_3x3_2 : nextstate = SYS_3x3_3; SYS_3x3_3 : nextstate = SYS_3x3_4;
        SYS_3x3_4 : nextstate = SYS_3x3_5; SYS_3x3_5 : nextstate = SYS_3x3_6; SYS_3x3_6 : nextstate = SYS_3x3_7;
        SYS_3x3_7 : nextstate = SYS_3x3_8; SYS_3x3_8 : nextstate = SYS_3x3_9; SYS_3x3_9 : nextstate = SYS_3x3_10;
        SYS_3x3_10 : nextstate = SYS_3x3_11; SYS_3x3_11 : nextstate = SYS_3x3_Wait; SYS_3x3_Wait : nextstate = SYS_3x3_RST;
        SYS_3x3_RST : nextstate = INITIAL;
        
        // --- 2x2 Systolic Array ?? ?? ---
        SYS_2x2_1 : nextstate = SYS_2x2_2; SYS_2x2_2 : nextstate = SYS_2x2_3; SYS_2x2_3 : nextstate = SYS_2x2_4;
        SYS_2x2_4 : nextstate = SYS_2x2_5; SYS_2x2_5 : nextstate = SYS_2x2_6; SYS_2x2_6 : nextstate = SYS_2x2_7;
        SYS_2x2_7 : nextstate = SYS_2x2_8; SYS_2x2_8 : nextstate = SYS_2x2_9; SYS_2x2_9 : nextstate = SYS_2x2_10;
        SYS_2x2_10 : nextstate = SYS_2x2_11; SYS_2x2_11 : nextstate = SYS_2x2_12; SYS_2x2_12 : nextstate = SYS_2x2_13;
        SYS_2x2_13 : nextstate = SYS_2x2_Wait; SYS_2x2_Wait : nextstate = SYS_2x2_RST; SYS_2x2_RST : nextstate = INITIAL;
        
        default: nextstate = INITIAL;
    endcase
end

// [Block 3] ?? ??: ?? ?? (Output Logic)
// ??? ?? ????? ?? ?(Data Path)? ??? ??? ??.
always @(*) begin
    // [??] ?? ??? ??(Default)?? ?? ???? ?? ????, 
    // case ??? ?? ?? ?????? ?? ?? ??? ???? ??? ??? ??.
    reg_rst_PE = 1'b1;
    reg_rst_SYS_3x3 = 1'b1;
    reg_rst_SYS_2x2 = 1'b1;
    reg_addr_mem_A1 = 8'b0; reg_addr_mem_A2 = 8'b0; reg_addr_mem_A3 = 8'b0;
    reg_addr_mem_F1 = 8'b0; reg_addr_mem_F2 = 8'b0; reg_addr_mem_F3 = 8'b0;

    case (state)
        INITIAL: begin
            // Default ?? ??? ?? ?? (?? ?? Reset ??)
        end
        
        // =====================================================================
        // Single PE ?? ??
        // =====================================================================
        C11_PE_1 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA11; reg_addr_mem_F1 = outF33; end
        C11_PE_2 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA12; reg_addr_mem_F1 = outF32; end
        C11_PE_3 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA13; reg_addr_mem_F1 = outF31; end
        C11_PE_4 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA21; reg_addr_mem_F1 = outF23; end
        C11_PE_5 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_F1 = outF22; end
        C11_PE_6 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_F1 = outF21; end
        C11_PE_7 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA31; reg_addr_mem_F1 = outF13; end
        C11_PE_8 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_F1 = outF12; end
        C11_PE_9 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA33; reg_addr_mem_F1 = outF11; end
        C11_PE_Wait : begin reg_rst_PE = 1'b0; end
        C11_PE_RST : begin reg_rst_PE = 1'b1; end // ?? ??? ?? PE? Reset
        
        C12_PE_1 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA12; reg_addr_mem_F1 = outF33; end
        C12_PE_2 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA13; reg_addr_mem_F1 = outF32; end
        C12_PE_3 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA14; reg_addr_mem_F1 = outF31; end
        C12_PE_4 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_F1 = outF23; end
        C12_PE_5 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_F1 = outF22; end
        C12_PE_6 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA24; reg_addr_mem_F1 = outF21; end
        C12_PE_7 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_F1 = outF13; end
        C12_PE_8 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA33; reg_addr_mem_F1 = outF12; end
        C12_PE_9 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA34; reg_addr_mem_F1 = outF11; end
        C12_PE_Wait : begin reg_rst_PE = 1'b0; end
        C12_PE_RST : begin reg_rst_PE = 1'b1; end
        
        C21_PE_1 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA21; reg_addr_mem_F1 = outF33; end
        C21_PE_2 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_F1 = outF32; end
        C21_PE_3 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_F1 = outF31; end
        C21_PE_4 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA31; reg_addr_mem_F1 = outF23; end
        C21_PE_5 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_F1 = outF22; end
        C21_PE_6 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA33; reg_addr_mem_F1 = outF21; end
        C21_PE_7 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA41; reg_addr_mem_F1 = outF13; end
        C21_PE_8 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA42; reg_addr_mem_F1 = outF12; end
        C21_PE_9 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA43; reg_addr_mem_F1 = outF11; end
        C21_PE_Wait : begin reg_rst_PE = 1'b0; end
        C21_PE_RST : begin reg_rst_PE = 1'b1; end
        
        C22_PE_1 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_F1 = outF33; end
        C22_PE_2 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_F1 = outF32; end
        C22_PE_3 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA24; reg_addr_mem_F1 = outF31; end
        C22_PE_4 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_F1 = outF23; end
        C22_PE_5 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA33; reg_addr_mem_F1 = outF22; end
        C22_PE_6 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA34; reg_addr_mem_F1 = outF21; end
        C22_PE_7 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA42; reg_addr_mem_F1 = outF13; end
        C22_PE_8 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA43; reg_addr_mem_F1 = outF12; end
        C22_PE_9 : begin reg_rst_PE = 1'b0; reg_addr_mem_A1 = outA44; reg_addr_mem_F1 = outF11; end
        C22_PE_Wait : begin reg_rst_PE = 1'b0; end
        C22_PE_RST : begin reg_rst_PE = 1'b1; end
        
        // =====================================================================
        // 3x3 Systolic Array ?? ?? (?? F? ?? ? ????? Default 0 ??)
        // =====================================================================
        SYS_3x3_1 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA14; end  
        SYS_3x3_2 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA13; reg_addr_mem_A2 = outA24; end
        SYS_3x3_3 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA12; reg_addr_mem_A2 = outA23; reg_addr_mem_A3 = outA34; end  
        SYS_3x3_4 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA11; reg_addr_mem_A2 = outA22; reg_addr_mem_A3 = outA33; end  
        SYS_3x3_5 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA24; reg_addr_mem_A2 = outA21; reg_addr_mem_A3 = outA32; end
        SYS_3x3_6 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_A2 = outA34; reg_addr_mem_A3 = outA31; end
        SYS_3x3_7 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_A2 = outA33; reg_addr_mem_A3 = outA44; end
        SYS_3x3_8 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A1 = outA21; reg_addr_mem_A2 = outA32; reg_addr_mem_A3 = outA43; end
        SYS_3x3_9 : begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A2 = outA31; reg_addr_mem_A3 = outA42; end
        SYS_3x3_10: begin reg_rst_SYS_3x3 = 1'b0; reg_addr_mem_A3 = outA41; end
        SYS_3x3_11: begin reg_rst_SYS_3x3 = 1'b0; end
        SYS_3x3_Wait : begin reg_rst_SYS_3x3 = 1'b0; end
        SYS_3x3_RST : begin reg_rst_SYS_3x3 = 1'b1; end
          
        // =====================================================================
        // 2x2 Systolic Array ?? ??
        // =====================================================================
        SYS_2x2_1 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA33; reg_addr_mem_A2 = outA44; reg_addr_mem_F1 = outF11; reg_addr_mem_F2 = outF11; end
        SYS_2x2_2 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_A2 = outA43; reg_addr_mem_F1 = outF12; reg_addr_mem_F2 = outF12; end
        SYS_2x2_3 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA24; reg_addr_mem_A2 = outA42; reg_addr_mem_F2 = outF13; end
        SYS_2x2_4 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA23; reg_addr_mem_A2 = outA34; reg_addr_mem_F1 = outF21; reg_addr_mem_F2 = outF21; end
        SYS_2x2_5 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA22; reg_addr_mem_A2 = outA33; reg_addr_mem_F1 = outF22; reg_addr_mem_F2 = outF22; end  
        SYS_2x2_6 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA14; reg_addr_mem_A2 = outA32; reg_addr_mem_F2 = outF23; end
        SYS_2x2_7 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA13; reg_addr_mem_A2 = outA24; reg_addr_mem_F1 = outF31; reg_addr_mem_F2 = outF31; end
        SYS_2x2_8 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA12; reg_addr_mem_A2 = outA23; reg_addr_mem_F1 = outF32; reg_addr_mem_F2 = outF32; end
        SYS_2x2_9 : begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA34; reg_addr_mem_A2 = outA22; reg_addr_mem_F2 = outF33; end
        SYS_2x2_10: begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA11; reg_addr_mem_F1 = outF33; reg_addr_mem_F2 = outF11; end
        SYS_2x2_11: begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA21; reg_addr_mem_A2 = outA21; reg_addr_mem_F1 = outF23; end
        SYS_2x2_12: begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA31; reg_addr_mem_A2 = outA31; reg_addr_mem_F1 = outF13; end
        SYS_2x2_13: begin reg_rst_SYS_2x2 = 1'b0; reg_addr_mem_A1 = outA32; reg_addr_mem_A2 = outA41; end
        SYS_2x2_Wait : begin reg_rst_SYS_2x2 = 1'b0; end
        SYS_2x2_RST : begin reg_rst_SYS_2x2 = 1'b1; end
        
    endcase  
end   

endmodule