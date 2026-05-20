module ps2_keyboard(
    input clk_25MHz, 
	 input rst_n, 
	 input PS2_CLK, 
	 input PS2_DAT,
    output reg p1_up, 
	 output reg p1_down, 
	 output reg p1_left, 
	 output reg p1_right,
    output reg p2_up, 
	 output reg p2_down, 
	 output reg p2_left, 
	 output reg p2_right,
	 output reg p1_space
);
    reg [10:0] shift_reg; 
    reg [3:0] bit_cnt; 
    reg [7:0] scan;
    reg ready, f0, s0, s1;

    // Bắt sườn xuống của xung nhịp bàn phím
    always @(posedge clk_25MHz) begin s0 <= PS2_CLK; s1 <= s0; end
    wire fall = (s1 && !s0);

    // Đọc dữ liệu 11-bit từ bàn phím
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 4'd0; 
            ready <= 1'b0;
        end else if (fall) begin
            shift_reg <= {PS2_DAT, shift_reg[10:1]};
            if (bit_cnt == 10) begin 
                scan <= shift_reg[9:2]; 
                ready <= 1'b1; 
                bit_cnt <= 4'd0; 
            end else begin 
                bit_cnt <= bit_cnt + 4'b1; 
                ready <= 1'b0; 
            end
        end else begin
            ready <= 1'b0;
        end
    end
    
    // Giải mã Scan Code thành tín hiệu nút bấm
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            f0 <= 1'b0;
            {p1_up, p1_down, p1_left, p1_right} <= 4'b0;
            {p2_up, p2_down, p2_left, p2_right} <= 4'b0;
        end else if (ready) begin
            if (scan == 8'hF0) begin
                f0 <= 1'b1; // Nhận mã ngắt (Break Code) -> Chuẩn bị nhả phím
            end else begin
                if (f0) begin 
                    // Player 1 (W-A-S-D)
                    if (scan == 8'h1D) p1_up    <= 1'b0;   
                    if (scan == 8'h1B) p1_down  <= 1'b0;
                    if (scan == 8'h1C) p1_left  <= 1'b0;   
                    if (scan == 8'h23) p1_right <= 1'b0;
                    if (scan == 8'h29) p1_space <= 1'b0;
						  
                    // Player 2 (I-J-K-L)
                    if (scan == 8'h43) p2_up    <= 1'b0;   
                    if (scan == 8'h42) p2_down  <= 1'b0;
                    if (scan == 8'h3B) p2_left  <= 1'b0;   
                    if (scan == 8'h4B) p2_right <= 1'b0;
                    
                    f0 <= 1'b0; 
                end else begin 
                    // Player 1 (W-A-S-D)
                    if (scan == 8'h1D) p1_up    <= 1'b1;   
                    if (scan == 8'h1B) p1_down  <= 1'b1;
                    if (scan == 8'h1C) p1_left  <= 1'b1;   
                    if (scan == 8'h23) p1_right <= 1'b1;
                    if (scan == 8'h29) p1_space <= 1'b1;
						  
                    // Player 2 (I-J-K-L)
                    if (scan == 8'h43) p2_up    <= 1'b1;   
                    if (scan == 8'h42) p2_down  <= 1'b1;
                    if (scan == 8'h3B) p2_left  <= 1'b1;   
                    if (scan == 8'h4B) p2_right <= 1'b1;
                end
            end
        end
    end
endmodule