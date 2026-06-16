//이 모듈은 어떤 값을 디스플레이에 출력할지 결정하는 무어 상태 머신입니다.

module display_FSM_module #(
    parameter fsm_cnt_max = 27'd99_999_999 //클럭을 100,000,000 분주하여 enable 신호 생성
    )(
    input [7:0] sa_2x2_11,
    input [7:0] sa_2x2_12,
    input [7:0] sa_2x2_21,
    input [7:0] sa_2x2_22,
    input [7:0] sa_3x3_11,
    input [7:0] sa_3x3_12,
    input [7:0] sa_3x3_21,
    input [7:0] sa_3x3_22,
    input clk,
    input rst,
    output reg [7:0] display_data,
    output [2:0] state
    );
    
    //1초(100M 클럭)마다 enable 신호 생성
    reg [26:0] clk_cnt;
    wire fsm_clk_en;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            clk_cnt <= 27'd0;
        end
        else begin
            if (clk_cnt == fsm_cnt_max) begin
                clk_cnt <= 27'd0;
            end
            else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end
    
    assign fsm_clk_en = (clk_cnt == fsm_cnt_max);

    //FSM 상태
    reg [3:0] current_state, next_state;

    localparam SA_3X3_11 = 3'd0, SA_3X3_12 = 3'd1, SA_3X3_21 = 3'd2, SA_3X3_22 = 3'd3,
               SA_2X2_11 = 3'd4, SA_2X2_12 = 3'd5, SA_2X2_21 = 3'd6, SA_2X2_22 = 3'd7;
    
    //FSM - Moore machine
    //현재 상태 업데이트
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= SA_3X3_11;
        end
        else if (fsm_clk_en) begin
            current_state <= next_state;
        end
    end

    //다음 상태 결정
    always @ (*) begin
        case(current_state)
            SA_3X3_11 : next_state = SA_3X3_12;
            SA_3X3_12 : next_state = SA_3X3_21;
            SA_3X3_21 : next_state = SA_3X3_22;
            SA_3X3_22 : next_state = SA_2X2_11;
            
            SA_2X2_11 : next_state = SA_2X2_12;
            SA_2X2_12 : next_state = SA_2X2_21;
            SA_2X2_21 : next_state = SA_2X2_22;
            SA_2X2_22 : next_state = SA_3X3_11;
            default   : next_state = SA_3X3_11;
        endcase
    end

    //출력 결정
    always @ (*) begin
        case(current_state)
            SA_2X2_11 : display_data = sa_2x2_11;
            SA_2X2_12 : display_data = sa_2x2_12;
            SA_2X2_21 : display_data = sa_2x2_21;
            SA_2X2_22 : display_data = sa_2x2_22; 

            SA_3X3_11 : display_data = sa_3x3_11;
            SA_3X3_12 : display_data = sa_3x3_12;
            SA_3X3_21 : display_data = sa_3x3_21;
            SA_3X3_22 : display_data = sa_3x3_22;
            default   : display_data = 8'd0;      
        endcase
    end

endmodule
