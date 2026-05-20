module snake_logic(
    input  wire       clk_25MHz, rst_n, init_en, update_en, 
    input  wire       btn_up, btn_down, btn_left, btn_right, 
    input  wire [9:0] pixel_x, pixel_y,
    output wire       is_snake, is_apple, 
    output reg        dead, 
    output reg  [7:0] score,
    
    // 2 DÂY NÀY ĐỂ BÁO TỌA ĐỘ ĐẦU RẮN RA NGOÀI CHO DISPLAY
    output wire [5:0] head_x, 
    output wire [4:0] head_y
);
    wire [5:0] grid_x = pixel_x[9:4]; 
    wire [4:0] grid_y = pixel_y[9:4]; 
    
    reg [5:0] body_x [0:127], apple_x, rand_x;
    reg [4:0] body_y [0:127], apple_y, rand_y;
    reg [7:0] len; 
    reg [21:0] timer_cnt; 
    
    // TỐC ĐỘ RẤT CHẬM (Bắt đầu từ 8 triệu xung clock)
    wire [21:0] speed_calc = 22'd8_000_000 - (score * 22'd200_000);
    wire [21:0] TICK_MAX   = (speed_calc < 22'd2_000_000) ? 22'd2_000_000 : speed_calc;
    wire tick = (timer_cnt >= TICK_MAX); 
    
    reg [1:0] dir, next_dir; 
    integer i;

    always @(posedge clk_25MHz) begin 
        rand_x <= (rand_x == 38) ? 6'd1 : rand_x + 6'd1; 
        rand_y <= (rand_y == 28) ? 5'd1 : rand_y + 5'd1;
    end

    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) dead <= 1'b0;
        else if (init_en) begin 
            dead <= 1'b0;
            len <= 8'd3; score <= 8'd0; 
            dir <= 2'd3; next_dir <= 2'd3; 
            body_x[0]<=20; 
				body_y[0]<=15; 
				body_x[1]<=19; 
				body_y[1]<=15; 
				body_x[2]<=18; 
				body_y[2]<=15;
            apple_x <= 30; 
				apple_y <= 15; 
            timer_cnt <= 22'd0;
				
        end else if (update_en && !dead) begin
            if      (btn_up    && dir != 2'd1) 
                next_dir <= 2'd0;
            else if (btn_down  && dir != 2'd0) 
                next_dir <= 2'd1;
            else if (btn_left  && dir != 2'd3) 
                next_dir <= 2'd2;
            else if (btn_right && dir != 2'd2) 
                next_dir <= 2'd3;
            
            timer_cnt <= tick ? 22'd0 : timer_cnt + 22'd1;
            if (tick) begin 
                dir <= next_dir;
                for (i = 127; i > 0; i = i - 1) begin
                    if (i < len) begin body_x[i] <= body_x[i-1]; body_y[i] <= body_y[i-1]; end
                end
                
                case (next_dir) 
                    2'd0: body_y[0] <= body_y[0] - 5'd1;
                    2'd1: body_y[0] <= body_y[0] + 5'd1; 
                    2'd2: body_x[0] <= body_x[0] - 6'd1; 
                    2'd3: body_x[0] <= body_x[0] + 6'd1;
                endcase
                
				if (body_x[0] == apple_x && body_y[0] == apple_y) begin 
                    if (len < 127) begin
                        len <= len + 8'd1;
                        body_x[len] <= body_x[len-1]; 
                        body_y[len] <= body_y[len-1];
                    end
                    apple_x <= rand_x; 
                    apple_y <= rand_y; 
                    score <= score + 8'd1;
                end
                
                if (body_x[0] >= 40 || body_y[0] >= 30) dead <= 1'b1;
                for (i = 1; i < 128; i = i + 1) begin
                    if (i < len && body_x[0] == body_x[i] && body_y[0] == body_y[i]) 
                        dead <= 1'b1;
                end
            end
        end
    end 


    reg check_snake;
    always @(*) begin 
        check_snake = 1'b0;
        for (i = 0; i < 128; i = i + 1) begin
            if (i < len && body_x[i] == grid_x && body_y[i] == grid_y) 
                check_snake = 1'b1;
        end
    end
    
    assign is_snake = check_snake;
    assign is_apple = (grid_x == apple_x && grid_y == apple_y);
    
    // Gán 2 dây đầu rắn ra ngoài
    assign head_x = body_x[0];
    assign head_y = body_y[0];

endmodule