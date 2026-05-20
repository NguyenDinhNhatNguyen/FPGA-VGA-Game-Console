module flappy_bird_logic(
    input  wire clk_25MHz, rst_n, init_en, update_en,
    input  wire btn_up,
    output reg  [9:0] bird_y, pipe_x, pipe_y,
    output reg  dead, output reg [7:0] score
);
    reg [19:0] f_cnt;
    wire tick = (f_cnt >= 20'd400_000); 

    reg [9:0] lfsr; 
    always @(posedge clk_25MHz) lfsr <= (lfsr==0) ? 10'h3FF : {lfsr[8:0], lfsr[9]^lfsr[6]};

    // Khai báo rõ kiểu SIGNED (có dấu)
    reg signed [12:0] velocity;
    reg signed [12:0] true_y;
    
    reg btn_prev;
    always @(posedge clk_25MHz) btn_prev <= btn_up;
    wire jump = btn_up & ~btn_prev;

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            true_y <= 13'sd240; 
				bird_y <= 10'd240; 
				velocity <= 13'sd0; 
            pipe_x <= 10'd640; 
				pipe_y <= 10'd200;
            dead <= 0; 
				score <= 0; 
				f_cnt <= 0;
        end else if (init_en) begin
            true_y <= 13'sd240; 
				bird_y <= 10'd240; 
				velocity <= 13'sd0; 
            pipe_x <= 10'd640; 
				pipe_y <= 10'd200;
            dead <= 0; 
				score <= 0;
				f_cnt <= 0;
        end else if (update_en && !dead) begin
            f_cnt <= tick ? 0 : f_cnt + 1;
            
            // Bấm nhảy (vận tốc âm)
            if (jump) 
                velocity <= -13'sd7; 
            
            if (tick) begin
                // Trọng lực kéo xuống 
                if (velocity < 13'sd10 && !jump) 
					     velocity <= velocity + 13'sd1;
                
                // CHÚ Ý: Mọi hằng số đem so sánh đều được thêm chữ 's' (Ví dụ: 13'sd460)
                if (true_y + velocity > 13'sd460) 
					     true_y <= 13'sd460;
                else if (true_y + velocity < 13'sd0) 
					     true_y <= 13'sd0;
                else true_y <= true_y + velocity;
                
                bird_y <= true_y[9:0]; 
                
                // Ống nước
                if (pipe_x <= 10'd5) begin 
                    pipe_x <= 10'd640;
                    score <= score + 1;
                    pipe_y <= 10'd80 + {3'b0, lfsr[6:0]} + {4'b0, lfsr[8:3]}; 
                end else begin
                    pipe_x <= pipe_x - 10'd4;
                end

                // Va chạm: Dùng hàm $signed() để bọc biến ống nước lại
                if (true_y >= 13'sd450 || true_y <= 13'sd5) dead <= 1; 
                if (pipe_x < 10'd320 && pipe_x + 10'd60 > 10'd300) begin
                    if (true_y < $signed({3'b0, pipe_y}) || true_y + 13'sd20 > $signed({3'b0, pipe_y}) + 13'sd120)
						      dead <= 1;
                end
            end
        end
    end
endmodule