//이 모듈은 입력받은 8비트 정수를 3개의 7세그먼트 디스플레이에 출력하는 드라이버 코드입니다.
module display_driver_module(
    input [7:0] in,
    input clk,
    input rst,
    output reg [6:0] seg_led,
    output reg [2:0] seg_digit
    );
    //이진수 데이터를 십진수로 변환
    wire [3:0] bcd_hundreds;
    wire [3:0] bcd_tens;
    wire [3:0] bcd_ones;
    
    // //기존 소프트웨어적 방식 - 최적화에 불리
    // assign bcd_hundreds = in / 100;
    // assign bcd_tens = (in % 100) / 10;
    // assign bcd_ones = in % 10;

    //Double Dabble 알고리즘을 활용하여 최적화
    reg [19:0] shift_reg; //3 * 4bit BCD + 8bit 입력 = 20bit
    integer i;

    always @ (*) begin
        shift_reg = 20'd0;
        shift_reg[7:0] = in;

        for (i = 0; i < 8; i = i + 1) begin
            if (shift_reg[11:8] >= 5) begin
                shift_reg[11:8] = shift_reg[11:8] + 3;
            end
            if (shift_reg[15:12] >= 5) begin
                shift_reg[15:12] = shift_reg[15:12] + 3;
            end
            if (shift_reg[19:16] >= 5) begin
                shift_reg[19:16] = shift_reg[19:16] + 3;
            end

            shift_reg = shift_reg << 1;
        end
    end

    assign bcd_ones = shift_reg[11:8];
    assign bcd_tens = shift_reg[15:12];
    assign bcd_hundreds = shift_reg[19:16];
    
    //200,000 clock당 자리 변경(500Hz)
    reg [1:0] digit_sel;
    reg [17:0] clk_cnt;
    
    wire seg_clk_en;

    parameter driver_cnt_max = 18'd199999; //클럭을 200,000분주하여 enable 신호 생성
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_cnt <= 18'd0;
        end
        else begin
            if (clk_cnt == driver_cnt_max) begin 
                clk_cnt <= 18'd0;
            end
            else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end
    end

    //카운터가 199,999일 때만 seg_clk_en을 1로 (조건부 활성화 신호)
    assign seg_clk_en = (clk_cnt == driver_cnt_max);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            digit_sel <= 2'd0;
        end
        // 분주된 클럭을 항상 블록에 직접 넣지 않고, 메인 클럭을 쓰되
        // 200,000번 중 딱 1번만 이 내부 로직이 실행
        else if (seg_clk_en) begin 
            if (digit_sel == 2'd2) begin
                digit_sel <= 2'd0;
            end
            else begin
                digit_sel <= digit_sel + 1'b1;
            end
        end
    end

    //자리 이동 및 데이터 할당 (Common Cathode: 1일 때 해당 자리가 켜짐)
    reg [3:0] current_bcd;
    
    always @(*) begin
        case(digit_sel)
            2'd0: begin
                seg_digit = 3'b001;     // 1의 자리 켬
                current_bcd = bcd_ones;
            end
            2'd1: begin
                seg_digit = 3'b010;     // 10의 자리 켬
                current_bcd = bcd_tens;
            end
            2'd2: begin
                seg_digit = 3'b100;     // 100의 자리 켬
                current_bcd = bcd_hundreds;
            end
            default: begin
                seg_digit = 3'b000;     // 모두 끔
                current_bcd = 4'd0;
            end
        endcase
    end

    // 4. BCD 데이터를 7-세그먼트 패턴으로 디코딩 (Common Cathode: 1일 때 켜짐)
    // 인덱스 배열: [6]=g, [5]=f, [4]=e, [3]=d, [2]=c, [1]=b, [0]=a
    always @(*) begin
        case(current_bcd)
            4'd0: seg_led = 7'b0111111;
            4'd1: seg_led = 7'b0000110;
            4'd2: seg_led = 7'b1011011;
            4'd3: seg_led = 7'b1001111;
            4'd4: seg_led = 7'b1100110;
            4'd5: seg_led = 7'b1101101;
            4'd6: seg_led = 7'b1111101;
            4'd7: seg_led = 7'b0000111; 
            4'd8: seg_led = 7'b1111111;
            4'd9: seg_led = 7'b1101111;
            default: seg_led = 7'b0000000; // 에러 시 모두 끔
        endcase
    end

endmodule
