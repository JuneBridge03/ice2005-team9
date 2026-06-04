module top_module(
    input CLK,
    input RST,
    output [6:0] SEG_LED,
    output [2:0] SEG_DIGIT,
    output done,
    output [2:0] LED
    );
    /*디스플레이 테스트용.
    localparam PE_11 = 8'd47, PE_12 = 8'd134, PE_21 = 8'd89, PE_22 = 8'd210,
               SA_2X2_11 = 8'd15, SA_2X2_12 = 8'd173, SA_2X2_21 = 8'd66, SA_2X2_22 = 8'd251,
               SA_3X3_11 = 8'd92, SA_3X3_12 = 8'd105, SA_3X3_21 = 8'd198, SA_3X3_22 = 8'd33; 
    -----------------------------------*/
    
//     localparam FLAT_IMAGE = {
//     8'd1,  8'd2,  8'd3,  8'd4,
//     8'd5,  8'd6,  8'd7,  8'd8,
//     8'd9,  8'd10, 8'd11, 8'd12,
//     8'd13, 8'd14, 8'd15, 8'd16
// }, 
// FLAT_KERNAL = {
//     8'd1, 8'd2, 8'd0,
//     8'd0, 8'd1, 8'd1,
//     8'd2, 8'd0, 8'd1
// };



    wire write, display_en;
    wire [127:0] FLAT_IMAGE;
    wire [71:0]  FLAT_KERNAL;
    wire [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe;
    wire [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;

    controller ctrl (.clk(CLK), .rst(~RST), .start(1'b1), .write(write), .display_en(display_en));

    memory mem (.clk(CLK), .rst(~RST), .write(write),
                .A11(8'd1),  .A12(8'd2),  .A13(8'd3),  .A14(8'd4),
                .A21(8'd5),  .A22(8'd6),  .A23(8'd7),  .A24(8'd8),
                .A31(8'd9),  .A32(8'd10),  .A33(8'd11),  .A34(8'd12),
                .A41(8'd13),  .A42(8'd14),  .A43(8'd15),  .A44(8'd16),
    
                 // 3x3 필터 데이터 입력 포트 (0, 1, 2 위주의 가중치)
                .F11(8'd1),  .F12(8'd2),  .F13(8'd0),
                .F21(8'd0),  .F22(8'd1),  .F23(8'd1),
                .F31(8'd2),  .F32(8'd0),  .F33(8'd1),
                .flat_image(FLAT_IMAGE), .flat_kernel(FLAT_KERNAL));

    TOP_Convolution calc( .clk(CLK), .rst(~RST || write), .flat_image(FLAT_IMAGE), .flat_kernel(FLAT_KERNAL), .c11_pe(c11_pe),   .c12_pe(c12_pe),   .c21_pe(c21_pe),   .c22_pe(c22_pe),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3), .done(done));
    
    display_module disp (.sa_2x2_11(c11_2x2), .sa_2x2_12(c12_2x2), .sa_2x2_21(c21_2x2), .sa_2x2_22(c22_2x2), .sa_3x3_11(c11_3x3), .sa_3x3_12(c12_3x3), .sa_3x3_21(c21_3x3), .sa_3x3_22(c22_3x3), .clk(CLK), .rst(~display_en), .seg_led(SEG_LED), .seg_digit(SEG_DIGIT), .state(LED) );
    
endmodule