module breakout_logic(
    input clk_25MHz, rst_n, init_en, update_en, btn_left, btn_right, 
    output reg [9:0] bx, by, px, output reg [7:0] bricks, output reg dead, output reg [7:0] score
);
    reg signed [10:0] x, y, vx, vy; reg [19:0] f_cnt; integer i;
    wire [19:0] spd = 20'd416_666 - (score * 20'd15_000); wire [19:0] TICK_MAX = (spd < 20'd120_000) ? 20'd120_000 : spd;
    wire tick = (f_cnt >= TICK_MAX); 
    always @(*) begin bx = x[9:0]; by = y[9:0]; end

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) dead <= 0; 
        else if (init_en) begin {x,y,vx,vy,dead} <= {11'd320, 11'd400, 11'd3, -11'd4, 1'b0}; px <= 280; bricks <= 8'hFF; score <= 0; end 
        else if (update_en && !dead) begin
            f_cnt <= tick ? 0 : f_cnt + 1; 
            if (tick) begin
                if (btn_left && px >= 6) px <= px - 8; 
					 else if (btn_right && px <= 554) 
					     px <= px + 8;
                    x <= x + vx; y <= y + vy; 
                if (x <= 5) begin 
					     x <= 6; 
					     vx <= -vx; 
					 end else if (x >= 625) begin 
					    x <= 624; 
						 vx <= -vx; 
					 end
                if (y <= 5) begin 
					    y <= 6; 
						 vy <= -vy; 
					 end if (y >= 470) 
					     dead <= 1;
                
                // DỘI RANDOM THEO VỊ TRÍ ĐỠ
                if (y >= 440 && y <= 450 && x + 10 >= px && x <= px + 80) begin 
                    y <= 439; vy <= -vy; 
                    if (x + 5 < px + 20) 
						     vx <= -11'd5; 
						  else if (x + 5 < px + 40)
						           vx <= -11'd2; 
                    else if (x + 5 < px + 60) 
						           vx <= 11'd2; 
						  else vx <= 11'd5;
                end
					 
                for (i = 0; i < 8; i = i + 1) begin
				 if (bricks[i] && y <= 70 && y >= 50 && x >= 40 + (i*70) && x <= 110 + (i*70)) begin 
					 bricks[i] <= 1'b0; // Phá vỡ gạch
					 vy <= -vy;         // Dội bóng
					 score <= score + 8'd1; // Chỉ cộng 1 điểm duy nhất cho viên này
					 end
				 end
                if (bricks == 8'h00) 
					     bricks <= 8'hFF;
            end
        end
    end
endmodule