module top_module(
    input CLK,
    input RST,
    output [6:0] SEG_LED,
    output [2:0] SEG_DIGIT,
    output done
    );
    /*디스플레이 테스트용.
    localparam PE_11 = 8'd47, PE_12 = 8'd134, PE_21 = 8'd89, PE_22 = 8'd210,
               SA_2X2_11 = 8'd15, SA_2X2_12 = 8'd173, SA_2X2_21 = 8'd66, SA_2X2_22 = 8'd251,
               SA_3X3_11 = 8'd92, SA_3X3_12 = 8'd105, SA_3X3_21 = 8'd198, SA_3X3_22 = 8'd33; 
    -----------------------------------*/
    
    localparam FLAT_IMAGE = {
    8'd1,  8'd2,  8'd3,  8'd4,
    8'd5,  8'd6,  8'd7,  8'd8,
    8'd9,  8'd10, 8'd11, 8'd12,
    8'd13, 8'd14, 8'd15, 8'd16
}, 
FLAT_KERNAL = {
    8'd1, 8'd2, 8'd0,
    8'd0, 8'd1, 8'd1,
    8'd2, 8'd0, 8'd1
};

    wire [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe;
    wire [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;

    

    TOP_Convolution calc( .clk(CLK), .rst(~RST), .flat_image(FLAT_IMAGE), .flat_kernel(FLAT_KERNAL), .c11_pe(c11_pe),   .c12_pe(c12_pe),   .c21_pe(c21_pe),   .c22_pe(c22_pe),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3), .done(done));
    
    display_module disp ( .pe_11(c11_pe), .pe_12(c12_pe), .pe_21(c21_pe), .pe_22(c22_pe), .sa_2x2_11(c11_2x2), .sa_2x2_12(c12_2x2), .sa_2x2_21(c21_2x2), .sa_2x2_22(c22_2x2), .sa_3x3_11(c11_3x3), .sa_3x3_12(c12_3x3), .sa_3x3_21(c21_3x3), .sa_3x3_22(c22_3x3), .clk(CLK), .rst(~RST), .seg_led(SEG_LED), .seg_digit(SEG_DIGIT) );
    
endmodule