module tictactoe_logic(
    input  wire       clk, rst_n, init_en, update_en, 
    input  wire       btn_up, btn_down, btn_left, btn_right, btn_space, 
    output reg  [3:0] cursor, 
    output reg  [1:0] c0, c1, c2, c3, c4, c5, c6, c7, c8, 
    output reg        dead
);
    reg turn; // 0: Người (X), 1: Máy (O)
    
    // Chống dội/Trôi phím
    reg u_d, d_d, l_d, r_d, s_d; 
    always @(posedge clk) {u_d, d_d, l_d, r_d, s_d} <= {btn_up, btn_down, btn_left, btn_right, btn_space};
    wire p_up = btn_up && !u_d; wire p_dn = btn_down && !d_d; 
    wire p_lf = btn_left && !l_d; wire p_rt = btn_right && !r_d; wire p_sp = btn_space && !s_d;
    
    // Logic check Thắng/Hòa
    wire [1:0] w1=(c0!=0&&c0==c1&&c1==c2)?c0:0, w2=(c3!=0&&c3==c4&&c4==c5)?c3:0, w3=(c6!=0&&c6==c7&&c7==c8)?c6:0;
    wire [1:0] w4=(c0!=0&&c0==c3&&c3==c6)?c0:0, w5=(c1!=0&&c1==c4&&c4==c7)?c1:0, w6=(c2!=0&&c2==c5&&c5==c8)?c2:0;
    wire [1:0] w7=(c0!=0&&c0==c4&&c4==c8)?c0:0, w8=(c2!=0&&c2==c4&&c4==c6)?c2:0; 
    wire [1:0] win = w1|w2|w3|w4|w5|w6|w7|w8;
    wire is_draw = (c0!=0&&c1!=0&&c2!=0&&c3!=0&&c4!=0&&c5!=0&&c6!=0&&c7!=0&&c8!=0 && win==0);

    // ==========================================
    // BỘ NÃO AI (Ưu tiên: Giữa -> 4 Góc -> 4 Cạnh)
    // ==========================================
    wire [3:0] ai_move = 
        (c4 == 0) ? 4'd4 : 
        (c0 == 0) ? 4'd0 : (c2 == 0) ? 4'd2 : (c6 == 0) ? 4'd6 : (c8 == 0) ? 4'd8 : 
        (c1 == 0) ? 4'd1 : (c3 == 0) ? 4'd3 : (c5 == 0) ? 4'd5 : (c7 == 0) ? 4'd7 : 4'd15;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) dead <= 1'b0; 
        else if (init_en) begin 
            {c0, c1, c2, c3, c4, c5, c6, c7, c8} <= 18'd0; 
            cursor <= 4'd4; turn <= 1'b0; dead <= 1'b0; 
        end else if (update_en && !dead) begin
            if (turn == 1'b0) begin 
                // LƯỢT NGƯỜI CHƠI
                if (p_up && cursor > 2) cursor <= cursor - 4'd3; 
                if (p_dn && cursor < 6) cursor <= cursor + 4'd3; 
                if (p_lf && cursor % 3 != 0) cursor <= cursor - 4'd1; 
                if (p_rt && cursor % 3 != 2) cursor <= cursor + 4'd1;
                
                if (p_sp) begin
                    if (cursor==0 && c0==0) begin c0<=1; turn<=1; end 
                    if (cursor==1 && c1==0) begin c1<=1; turn<=1; end 
                    if (cursor==2 && c2==0) begin c2<=1; turn<=1; end
                    if (cursor==3 && c3==0) begin c3<=1; turn<=1; end 
                    if (cursor==4 && c4==0) begin c4<=1; turn<=1; end 
                    if (cursor==5 && c5==0) begin c5<=1; turn<=1; end
                    if (cursor==6 && c6==0) begin c6<=1; turn<=1; end 
                    if (cursor==7 && c7==0) begin c7<=1; turn<=1; end 
                    if (cursor==8 && c8==0) begin c8<=1; turn<=1; end
                end
            end else begin
                // LƯỢT CỦA MÁY (Phản xạ ngay lập tức)
                if (ai_move == 0) c0 <= 2; if (ai_move == 1) c1 <= 2; if (ai_move == 2) c2 <= 2;
                if (ai_move == 3) c3 <= 2; if (ai_move == 4) c4 <= 2; if (ai_move == 5) c5 <= 2;
                if (ai_move == 6) c6 <= 2; if (ai_move == 7) c7 <= 2; if (ai_move == 8) c8 <= 2;
                turn <= 1'b0; // Trả lại lượt cho người
            end
            
            if (win != 0 || is_draw) dead <= 1'b1;
        end
    end
endmodule