module invaders_logic(
    input  wire clk_25MHz, rst_n, init_en, update_en,
    input  wire btn_left, btn_right, btn_space, btn_up,
    output reg  [9:0] ship_x, laser_x, laser_y,
    output reg  [9:0] m1_x, m1_y, m2_x, m2_y, m3_x, m3_y,
    output reg  m1_a, m2_a, m3_a, output reg dead, output reg [7:0] score
);
    reg [9:0] lfsr; 
    always @(posedge clk_25MHz) lfsr <= (lfsr==0) ? 10'h3FF : {lfsr[8:0], lfsr[9]^lfsr[6]};
    
    reg [19:0] tick_cnt; 
    wire tick = (tick_cnt >= 20'd400_000); 

    reg up_prev, sp_prev;
    always @(posedge clk_25MHz) begin 
        up_prev <= btn_up; 
        sp_prev <= btn_space; 
    end
    wire shoot_edge = (btn_up & ~up_prev) | (btn_space & ~sp_prev); 

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin 
            // QUY TẮC VÀNG: MỌI BIẾN PHẢI ĐƯỢC RESET Ở ĐÂY ĐỂ TRÁNH LỖI 10200
            dead <= 1'b0; 
				score <= 8'd0; 
				tick_cnt <= 20'd0;
            ship_x <= 10'd300;
				laser_x <= 10'd0; 
				laser_y <= 10'd0; 
            m1_x <= 10'd0; 
				m1_y <= 10'd0; 
				m1_a <= 1'b0;
            m2_x <= 10'd0;
				m2_y <= 10'd0;
				m2_a <= 1'b0;
            m3_x <= 10'd0; 
				m3_y <= 10'd0; 
				m3_a <= 1'b0;
        end
        else if (init_en) begin
            dead <= 1'b0; 
				score <= 8'd0;
				tick_cnt <= 20'd0;
            ship_x <= 10'd300; 
				laser_x <= 10'd0; 
				laser_y <= 10'd0; 
            m1_x <= {1'b0, lfsr[8:0]}; 
				m1_y <= 10'd0; 
				m1_a <= 1'b1;
            m2_x <= 10'd600 - {2'b0, 
				lfsr[7:0]}; 
				m2_y <= 10'd0;
				m2_a <= 1'b1; 
            m3_x <= {2'b0,
				lfsr[9:2]} + 10'd200; 
				m3_y <= 10'd0; 
				m3_a <= 1'b1; 
        end
        else if (update_en && !dead) begin
            tick_cnt <= tick ? 20'd0 : tick_cnt + 20'd1;
            
            // BẤM LÀ BẮN (Bỏ điều kiện chặn, bấm liên tục đạn sẽ reset vị trí về nòng)
            if (shoot_edge) begin 
                laser_x <= ship_x + 10'd15; 
                laser_y <= 10'd420; 
            end
            
            if (tick_cnt[15:0] == 16'd0) begin
                if (btn_left && ship_x > 10'd10) 
					     ship_x <= ship_x - 10'd2;
                if (btn_right && ship_x < 10'd590) 
					     ship_x <= ship_x + 10'd2;
                
                if (laser_y > 10'd8) 
					     laser_y <= laser_y - 10'd8; 
                else if (laser_y > 10'd0) 
					     laser_y <= 10'd0; 
                
                if (laser_y > 0 && laser_y < m1_y + 10'd20 && laser_x > m1_x && laser_x < m1_x + 10'd30) begin 
                    m1_y <= 10'd0; 
						  m1_x <= {1'b0, lfsr[8:0]}; 
						  laser_y <= 10'd0;
						  score <= score + 8'd1; 
                end
                if (laser_y > 0 && laser_y < m2_y + 10'd20 && laser_x > m2_x && laser_x < m2_x + 10'd30) begin 
                    m2_y <= 10'd0;
						  m2_x <= 10'd600 - {2'b0, lfsr[7:0]};
						  laser_y <= 10'd0; 
						  score <= score + 8'd1; 
                end
                if (laser_y > 0 && laser_y < m3_y + 10'd20 && laser_x > m3_x && laser_x < m3_x + 10'd30) begin 
                    m3_y <= 10'd0; 
						  m3_x <= {2'b0, lfsr[9:2]} + 10'd200;
						  laser_y <= 10'd0; 
						  score <= score + 8'd1; 
                end
            end

            if (tick) begin
                m1_y <= m1_y + 10'd3; 
                m2_y <= m2_y + 10'd4; 
                m3_y <= m3_y + 10'd5;
                
                if (m1_y > 10'd480) begin 
					     m1_y <= 10'd0; 
						  m1_x <= {1'b0, lfsr[8:0]}; 
					 end
					 
                if (m2_y > 10'd480) begin
 					     m2_y <= 10'd0; 
						  m2_x <= 10'd600 - {2'b0, lfsr[7:0]}; 
					 end
					 
                if (m3_y > 10'd480) begin 
 					     m3_y <= 10'd0;
						  m3_x <= {2'b0, lfsr[9:2]} + 10'd200; 
					 end
					 
                if (m1_y + 10'd20 > 10'd420 && m1_x + 10'd30 > ship_x && m1_x < ship_x + 10'd40) 
					     dead <= 1'b1;
                if (m2_y + 10'd20 > 10'd420 && m2_x + 10'd30 > ship_x && m2_x < ship_x + 10'd40) 
 					     dead <= 1'b1;
                if (m3_y + 10'd20 > 10'd420 && m3_x + 10'd30 > ship_x && m3_x < ship_x + 10'd40)
 					     dead <= 1'b1;
            end
        end
    end
endmodule