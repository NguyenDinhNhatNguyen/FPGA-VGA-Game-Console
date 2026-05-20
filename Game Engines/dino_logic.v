module dino_logic(
    input  wire       clk_25MHz, rst_n, init_en, update_en, btn_up, 
    output reg  [9:0] dino_y, cactus_x, 
    output reg        dead, 
    output reg  [7:0] score
);
    reg signed [10:0] y, vy; 
    reg [19:0] f_cnt;
    reg passed; // Biến chốt để cộng điểm +1 chuẩn xác

    // Tốc độ game tăng dần từ từ sau mỗi điểm
    wire [19:0] speed_calc = 20'd750_000 - (score * 20'd5_000);
    wire [19:0] TICK_MAX   = (speed_calc < 20'd250_000) ? 20'd250_000 : speed_calc;
    wire tick = (f_cnt >= TICK_MAX);

    // Xử lý bắt cạnh nút bấm cho lệnh nhảy
    reg up_d, jump_pending;
    always @(posedge clk_25MHz) up_d <= btn_up;
    wire jump_edge = (btn_up && !up_d);

    always @(posedge clk_25MHz) begin
        if (init_en) 
		      jump_pending <= 1'b0;
        else if (jump_edge) 
		      jump_pending <= 1'b1;
        else if (tick) 
		      jump_pending <= 1'b0;
    end

    // === TOÀN BỘ LOGIC GOM VÀO 1 KHỐI ALWAYS DUY NHẤT ===
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            dead <= 1'b0; 
				score <= 8'd0; 
				passed <= 1'b0;
            y <= 11'd350; 
				vy <= 11'd0;
				cactus_x <= 10'd640;
        end 
        else if (init_en) begin
            dead <= 1'b0; 
				score <= 8'd0;
				passed <= 1'b0;
            y <= 11'd350;
				vy <= 11'd0; 
				cactus_x <= 10'd640;
        end 
        else if (update_en && !dead) begin
            f_cnt <= tick ? 20'd0 : f_cnt + 20'd1;
            
            if (tick) begin
                // 1. VẬT LÝ NHẢY (Nhảy cao gấp đôi xương rồng)
                if ((jump_pending || jump_edge) && y >= 350) 
                    vy <= -11'd80; // Lực nhảy mạnh
                else if (y < 350) 
                    vy <= vy + 11'd1; // Trọng lực nhẹ để bay bổng
                else 
                    vy <= 11'd0;
						  
						  y <= (y + vy > 350) ? 11'd350 : y + vy; 

                // 2. DI CHUYỂN XƯƠNG RỒNG
                if (cactus_x <= 5) begin 
                    cactus_x <= 10'd640;
                    passed <= 1'b0; // Reset chốt điểm khi xương rồng hồi sinh
                end 
                else begin
                    cactus_x <= cactus_x - 10'd6;
                end

                // 3. CỘNG ĐIỂM CHUẨN +1 (Khi vượt qua Dino ở x=100)
                if (cactus_x < 100 && !passed) begin
                    score <= score + 8'd1;
                    passed <= 1'b1; // Khóa chốt, không cho cộng thêm cho vật này
                end

                // 4. KIỂM TRA VA CHẠM
                // Hitbox: Dino ở x ~ 100, y. Xương rồng ở cactus_x, y=350.
                if (cactus_x <= 130 && cactus_x >= 80 && y >= 320) begin
                    dead <= 1'b1;
                end
            end
        end
    end

    always @(*) dino_y = y[9:0];

endmodule