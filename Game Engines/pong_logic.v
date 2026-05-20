module pong_logic(
    input  wire       clk_25MHz, rst_n, init_en, update_en, sw_2p,
    input  wire       p1_up, p1_down, p2_up, p2_down,
    input  wire       reset_menu,
    output wire [9:0] ball_x, ball_y,
    output reg  [9:0] paddle_L_y, paddle_R_y,
    output reg        dead, 
    output reg  [7:0] score,
    output reg  [2:0] p1_rounds, p2_rounds
);
    reg signed [10:0] x, y, vx, vy; 
    reg [19:0] f_cnt;
	 
	 reg [9:0] lfsr; 
	 always @(posedge clk_25MHz) 
		  lfsr <= (lfsr==0) ? 10'h3FF : {lfsr[8:0], 
		  lfsr[9]^lfsr[6]};
    
    wire [19:0] speed_calc = 20'd416_666 - (score * 20'd15_000);
    wire [19:0] TICK_MAX   = (speed_calc < 20'd100_000) ? 20'd100_000 : speed_calc; 
    wire tick = (f_cnt >= TICK_MAX);

    assign ball_x = x[9:0]; 
    assign ball_y = y[9:0];

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            p1_rounds <= 3'd0; p2_rounds <= 3'd0;
            {x, y, vx, vy, dead} <= {11'd315, 11'd235, 11'd3, 11'd3, 1'b0};
            {paddle_L_y, paddle_R_y} <= {10'd210, 10'd210};
            score <= 8'd0; f_cnt <= 20'd0;
        end 
        else if (reset_menu) begin
            p1_rounds <= 3'd0; p2_rounds <= 3'd0;
        end
        else if (init_en) begin
            // Ép bóng đứng im giữa màn hình lúc Countdown (vx=0, vy=0)
            {x, y, vx, vy, dead} <= {11'd315, 11'd235, 11'd0, 11'd0, 1'b0};
            {paddle_L_y, paddle_R_y} <= {10'd210, 10'd210};
            score <= 8'd0; f_cnt <= 20'd0;
        end
        else if (update_en && !dead) begin
            f_cnt <= tick ? 20'd0 : f_cnt + 20'd1;
            
            if (tick) begin
                // Phục hồi vận tốc khi game bắt đầu chạy
                if (vx == 0 && vy == 0) begin
                    vx <= 11'd3; vy <= 11'd3;
                end

                if (p1_up && paddle_L_y >= 5) paddle_L_y <= paddle_L_y - 10'd5;
                else if (p1_down && paddle_L_y <= 420) paddle_L_y <= paddle_L_y + 10'd5;
                
                if (sw_2p) begin
                    if (p2_up && paddle_R_y >= 5) paddle_R_y <= paddle_R_y - 10'd5;
                    else if (p2_down && paddle_R_y <= 420) paddle_R_y <= paddle_R_y + 10'd5;
                end else begin
                    // Thêm +- 15 pixel deadzone để AI không bị giật lùi liên tục
                    if (y > paddle_R_y + 45 && paddle_R_y <= 420) paddle_R_y <= paddle_R_y + 10'd4;
                    else if (y < paddle_R_y + 15 && paddle_R_y >= 5) paddle_R_y <= paddle_R_y - 10'd4;
                end
                
                x <= x + vx; y <= y + vy;
                
                if (y <= 5) begin y <= 6; vy <= -vy; end
                else if (y >= 465) begin y <= 464; vy <= -vy; end
                
                if (x <= 0) begin 
                    dead <= 1'b1; 
                    p2_rounds <= p2_rounds + 3'd1;
                end 
                else if (x >= 630) begin 
                    dead <= 1'b1; 
                    p1_rounds <= p1_rounds + 3'd1;
                end
                
                // Va chạm thanh trượt Trái
					 if (x <= 35 && x >= 20 && y+10 >= $signed({1'b0, paddle_L_y}) && y <= $signed({1'b0, paddle_L_y})+60) begin
                    vx <= -vx; x <= 36; 
                    // Random góc bật lên/xuống (từ 2 đến 5)
                    vy <= (y+5 < $signed({1'b0, paddle_L_y})+30) ? -($signed({8'b0, lfsr[1:0]}) + 2) : ($signed({8'b0, lfsr[1:0]}) + 2);
                    if (score < 255) score <= score + 8'd1;
                end 
                else if (x >= 595 && x <= 610 && y+10 >= $signed({1'b0, paddle_R_y}) && y <= $signed({1'b0, paddle_R_y})+60) begin
                    vx <= -vx; x <= 594; 
                    vy <= (y+5 < $signed({1'b0, paddle_R_y})+30) ? -($signed({8'b0, lfsr[1:0]}) + 2) : ($signed({8'b0, lfsr[1:0]}) + 2);
                    if (score < 255) score <= score + 8'd1;
                end
            end
        end
    end
endmodule