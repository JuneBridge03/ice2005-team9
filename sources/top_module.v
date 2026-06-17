module top_module(
    input CLK,
    input RST,
    output [6:0] SEG_LED,
    output [2:0] SEG_DIGIT
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

    //주어진 행렬 데이터를 여기에 넣을 것. Testbench에서는 override됨.
    // 4x4 이미지 행렬 a
    parameter [7:0] a11 = 8'd1,  a12 = 8'd2,  a13 = 8'd3,  a14 = 8'd4,
                    a21 = 8'd5,  a22 = 8'd6,  a23 = 8'd7,  a24 = 8'd8,
                    a31 = 8'd9,  a32 = 8'd10, a33 = 8'd11, a34 = 8'd12,
                    a41 = 8'd13, a42 = 8'd14, a43 = 8'd15, a44 = 8'd16;
    
    // 3x3 필터 행렬 f
    parameter [7:0] f11 = 8'd1,  f12 = 8'd2,  f13 = 8'd0,
                    f21 = 8'd0,  f22 = 8'd1,  f23 = 8'd1,
                    f31 = 8'd2,  f32 = 8'd0,  f33 = 8'd1;

    wire write, display_en;
    wire [127:0] FLAT_IMAGE;
    wire [71:0]  FLAT_KERNAL;
    wire [7:0] c11_pe,  c12_pe,  c21_pe,  c22_pe;
    wire [7:0] c11_2x2, c12_2x2, c21_2x2, c22_2x2;
    wire [7:0] c11_3x3, c12_3x3, c21_3x3, c22_3x3;

    controller ctrl (.clk(CLK), .rst(~RST), .start(1'b1), .write(write), .display_en(display_en));

    memory mem (
    .clk(CLK), .rst(~RST), .write(write),
    .A11(a11), .A12(a12), .A13(a13), .A14(a14),
    .A21(a21), .A22(a22), .A23(a23), .A24(a24),
    .A31(a31), .A32(a32), .A33(a33), .A34(a34),
    .A41(a41), .A42(a42), .A43(a43), .A44(a44),
    .F11(f11), .F12(f12), .F13(f13),
    .F21(f21), .F22(f22), .F23(f23),
    .F31(f31), .F32(f32), .F33(f33),
    .flat_image(FLAT_IMAGE), 
    .flat_kernel(FLAT_KERNAL)
    );

    TOP_Convolution calc( .clk(CLK), .rst(~RST || write), .flat_image(FLAT_IMAGE), .flat_kernel(FLAT_KERNAL), .c11_pe(c11_pe),   .c12_pe(c12_pe),   .c21_pe(c21_pe),   .c22_pe(c22_pe),
        .c11_2x2(c11_2x2), .c12_2x2(c12_2x2), .c21_2x2(c21_2x2), .c22_2x2(c22_2x2),
        .c11_3x3(c11_3x3), .c12_3x3(c12_3x3), .c21_3x3(c21_3x3), .c22_3x3(c22_3x3));
    
    display_module disp (.sa_2x2_11(c11_2x2), .sa_2x2_12(c12_2x2), .sa_2x2_21(c21_2x2), .sa_2x2_22(c22_2x2), .sa_3x3_11(c11_3x3), .sa_3x3_12(c12_3x3), .sa_3x3_21(c21_3x3), .sa_3x3_22(c22_3x3), .clk(CLK), .rst(~display_en), .seg_led(SEG_LED), .seg_digit(SEG_DIGIT));
    
endmodule