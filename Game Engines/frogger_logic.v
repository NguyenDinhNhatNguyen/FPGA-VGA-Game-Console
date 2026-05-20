module frogger_logic(
    input  wire clk_25MHz, rst_n, init_en, update_en,
    input  wire btn_up, btn_down, btn_left, btn_right,
    output reg  [9:0] frog_x, frog_y,
    output reg  [9:0] lane1_x, lane2_x, lane3_x, lane4_x, lane5_x,
    output wire map_type, 
    output reg  dead, output reg [7:0] score
);
    reg [19:0] f_cnt; reg [9:0] lfsr; 
    always @(posedge clk_25MHz) lfsr <= (lfsr == 0) ? 10'h3FF : {lfsr[8:0], lfsr[9] ^ lfsr[6]};

    wire [19:0] TICK_MAX = 20'd150_000 - (score * 20'd3_000); 
    wire tick = (f_cnt >= TICK_MAX);

    reg u_d, d_d, l_d, r_d;
    always @(posedge clk_25MHz) 
			{u_d, d_d, l_d, r_d} <= {btn_up, btn_down, btn_left, btn_right};
    wire p_up = btn_up & !u_d;
	 wire p_dn = btn_down & !d_d;
    wire p_lf = btn_left & !l_d;
	 wire p_rt = btn_right & !r_d;

    reg dir1, dir2, dir3, dir4, dir5;
    reg [2:0] spd1, spd2, spd3, spd4, spd5;
    
    assign map_type = ((score + 8'd1) % 8'd3 == 8'd0); // Điểm 2, 5, 8... sẽ có sông

    // HÀM KIỂM TRA VA CHẠM ĐA MỤC TIÊU (Nhân bản 4 vật thể cách đều 160px trên sông)
    function check_obj;
        input [9:0] fx, lx, w;
        input is_river;
        reg [9:0] o1, o2, o3;
        begin
            o1 = (lx + 10'd160 >= 10'd640) ? lx + 10'd160 - 10'd640 : lx + 10'd160;
            o2 = (lx + 10'd320 >= 10'd640) ? lx + 10'd320 - 10'd640 : lx + 10'd320;
            o3 = (lx + 10'd480 >= 10'd640) ? lx + 10'd480 - 10'd640 : lx + 10'd480;
            if (is_river) begin
                check_obj = (fx < lx + w && fx + 10'd20 > lx) ||
                            (fx < o1 + w && fx + 10'd20 > o1) ||
                            (fx < o2 + w && fx + 10'd20 > o2) ||
                            (fx < o3 + w && fx + 10'd20 > o3);
            end else begin
                check_obj = (fx < lx + 10'd40 && fx + 10'd20 > lx); // Xe đường bộ chỉ có 1 chiếc
            end
        end
    endfunction

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            dead <= 0; 
				score <= 0;
				frog_x <= 310;
				frog_y <= 440; 
				f_cnt <= 0;
            lane1_x <= 0; 
				lane2_x <= 0; 
				lane3_x <= 0; 
				lane4_x <= 0; lane5_x <= 0;
            dir1<=0; 
				dir2<=0; 
				dir3<=0; 
				dir4<=0; 
				dir5<=0;
            spd1<=0;
				spd2<=0; 
				spd3<=0; 
				spd4<=0; 
				spd5<=0;
        end 
        else if (init_en || (frog_y <= 60 && !dead)) begin
            dead <= 0; 
				f_cnt <= 0;
            score <= init_en ? 8'd0 : score + 8'd1;
            frog_x <= 310; 
				frog_y <= 440;
            
            dir1 <= lfsr[0]; 
				spd1 <= 3'd2 + lfsr[2:1];
            dir2 <= lfsr[1]; 
				spd2 <= 3'd2 + lfsr[3:2];
            dir3 <= lfsr[2]; 
				spd3 <= 3'd2 + lfsr[4:3];
            dir4 <= lfsr[3]; 
				spd4 <= 3'd2 + lfsr[5:4];
            dir5 <= lfsr[4]; 
				spd5 <= 3'd2 + lfsr[6:5];
            
            lane1_x <= {1'b0, lfsr[8:0]};
				lane2_x <= {1'b0, lfsr[7:0]}; 
				lane3_x <= {1'b0, lfsr[9:1]}; 
            lane4_x <= {1'b0, lfsr[6:0]}; 
				lane5_x <= {1'b0, lfsr[8:1]};
        end 
        else if (update_en && !dead) begin
            f_cnt <= tick ? 0 : f_cnt + 1;

            if (p_up && frog_y >= 20)  frog_y <= frog_y - 20;
            if (p_dn && frog_y <= 440) frog_y <= frog_y + 20;
            if (p_lf && frog_x >= 20)  frog_x <= frog_x - 20;
            if (p_rt && frog_x <= 600) frog_x <= frog_x + 20;

            if (tick) begin
                // ÉP TỐC ĐỘ VÀ HƯỚNG CỰC CHẬM NẾU LÀ SÔNG (1: Phải, 0: Trái)
                lane1_x <= dir1 ? ((lane1_x > 640) ? 0 : lane1_x + spd1) : ((lane1_x < spd1) ? 640 : lane1_x - spd1);
                lane2_x <= (map_type ? 1'b1 : dir2) ? ((lane2_x > 640) ? 0 : lane2_x + (map_type ? 3'd1 : spd2)) : ((lane2_x < (map_type ? 3'd1 : spd2)) ? 640 : lane2_x - (map_type ? 3'd1 : spd2));
                lane3_x <= (map_type ? 1'b0 : dir3) ? ((lane3_x > 640) ? 0 : lane3_x + (map_type ? 3'd1 : spd3)) : ((lane3_x < (map_type ? 3'd1 : spd3)) ? 640 : lane3_x - (map_type ? 3'd1 : spd3));
                lane4_x <= (map_type ? 1'b1 : dir4) ? ((lane4_x > 640) ? 0 : lane4_x + (map_type ? 3'd1 : spd4)) : ((lane4_x < (map_type ? 3'd1 : spd4)) ? 640 : lane4_x - (map_type ? 3'd1 : spd4));
                lane5_x <= dir5 ? ((lane5_x > 640) ? 0 : lane5_x + spd5) : ((lane5_x < spd5) ? 640 : lane5_x - spd5);

                // --- XÉT VA CHẠM 
                if (frog_y >= 380 && frog_y <= 400 && check_obj(frog_x, lane1_x, 10'd40, 1'b0)) dead <= 1;
                if (frog_y >= 80  && frog_y <= 100 && check_obj(frog_x, lane5_x, 10'd40, 1'b0)) dead <= 1;
                
                // Làn 2 (Gỗ rộng 80px)
                if (frog_y >= 300 && frog_y <= 320) begin
                    if (map_type) begin
                        if (check_obj(frog_x, lane2_x, 10'd80, 1'b1)) 
								    frog_x <= frog_x + 10'd1; // Trôi phải
                        else dead <= 1; 
                    end else if (check_obj(frog_x, lane2_x, 10'd40, 1'b0)) 
						           dead <= 1;
                end

                // Làn 3 (Sen rộng 40px)
                if (frog_y >= 220 && frog_y <= 240) begin
                    if (map_type) begin
                        if (check_obj(frog_x, lane3_x, 10'd40, 1'b1)) 
								    frog_x <= frog_x - 10'd1; // Trôi trái
                        else dead <= 1;
                    end else if (check_obj(frog_x, lane3_x, 10'd40, 1'b0)) 
						           dead <= 1;
                end

                // Làn 4 (Gỗ rộng 80px)
                if (frog_y >= 140 && frog_y <= 160) begin
                    if (map_type) begin
                        if (check_obj(frog_x, lane4_x, 10'd80, 1'b1)) 
								    frog_x <= frog_x + 10'd1; // Trôi phải
                        else dead <= 1;
                    end else if (check_obj(frog_x, lane4_x, 10'd40, 1'b0)) 
						           dead <= 1;
                end
                
                if (frog_x < 5 || frog_x > 620) 
					     dead <= 1'b1;
            end
        end
    end
endmodule