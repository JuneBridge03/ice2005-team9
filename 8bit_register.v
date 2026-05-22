
// 8-bit register module
module eight_bit_register_structural_module(in, clk, en, rst, out);
    
    input clk;       // clock
    input rst;       // reset
    input en;        // write enable (Memory 모듈에서 write 신호를 받음)
    input [7:0] in;  // input matrix (8비트 입력 데이터)

    output [7:0] out; 
    wire [7:0] out;  // 출력을 연결하기 위한 wire 선언

    // 1비트 D 플립플롭 8개를 불러와서 각각의 비트(0번~7번)에 연결
    // .q_bar()는 괄호를 비워두어 사용하지 않는 출력은 연결하지 않고 버림(Unconnected)
    d_flip_flop_1bit_module register_0(.rst(rst), .en(en), .d(in[0]), .clk(clk), .q(out[0]), .q_bar());
    d_flip_flop_1bit_module register_1(.rst(rst), .en(en), .d(in[1]), .clk(clk), .q(out[1]), .q_bar());
    d_flip_flop_1bit_module register_2(.rst(rst), .en(en), .d(in[2]), .clk(clk), .q(out[2]), .q_bar());
    d_flip_flop_1bit_module register_3(.rst(rst), .en(en), .d(in[3]), .clk(clk), .q(out[3]), .q_bar());
    d_flip_flop_1bit_module register_4(.rst(rst), .en(en), .d(in[4]), .clk(clk), .q(out[4]), .q_bar());
    d_flip_flop_1bit_module register_5(.rst(rst), .en(en), .d(in[5]), .clk(clk), .q(out[5]), .q_bar());
    d_flip_flop_1bit_module register_6(.rst(rst), .en(en), .d(in[6]), .clk(clk), .q(out[6]), .q_bar());
    d_flip_flop_1bit_module register_7(.rst(rst), .en(en), .d(in[7]), .clk(clk), .q(out[7]), .q_bar());

endmodule

endmodule
