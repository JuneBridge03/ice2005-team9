
module d_flip_flop_1bit_module (d, clk, rst, en, q, q_bar);

    input d, clk, rst, en; // d: 입력 데이터, clk: 클럭, rst: 리셋, en: 쓰기 활성화
    
    output q, q_bar;       // q: 출력 데이터, q_bar: 반전된 출력 데이터(!q)
    reg q, q_bar;          // always 블록 안에서 값을 할당하기 위해 reg로 선언

    // clk의 상승 에지(0->1) 또는 rst의 상승 에지에서 동작 (비동기 리셋)
    always@(posedge clk or posedge rst)
    begin
        if(rst == 1'b1)
        begin
            // 리셋 신호가 들어오면 무조건 0으로 초기화
            q <= 1'b0;
            q_bar <= 1'b1;
        end
        else
        begin
            // 리셋이 아닐 때
            if(en == 1'b1)
            begin
                // Enable(쓰기 활성화) 신호가 1일 때만 입력 d를 q에 저장
                q <= d;
                q_bar <= !d;
            end
            else
            begin
                // Enable 신호가 0이면 이전 데이터(q)를 그대로 유지 (기억)
                q <= q;
                q_bar <= !q;
            end
        end
    end
endmodule
