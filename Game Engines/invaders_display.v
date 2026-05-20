module invaders_display(
    input [9:0] x_pos, y_pos, ship_x, laser_x, laser_y,
    input [9:0] m1_x, m1_y, m2_x, m2_y, m3_x, m3_y,
    input m1_a, m2_a, m3_a, video_on, 
    output reg [9:0] R, G, B
);
    wire is_ship = (x_pos >= ship_x && x_pos <= ship_x + 40 && y_pos >= 420 && y_pos <= 460);
    wire is_m1   = (m1_a && x_pos >= m1_x && x_pos <= m1_x + 40 && y_pos >= m1_y && y_pos <= m1_y + 40);
    wire is_m2   = (m2_a && x_pos >= m2_x && x_pos <= m2_x + 40 && y_pos >= m2_y && y_pos <= m2_y + 40);
    wire is_m3   = (m3_a && x_pos >= m3_x && x_pos <= m3_x + 40 && y_pos >= m3_y && y_pos <= m3_y + 40);
    wire is_las  = (x_pos >= laser_x && x_pos <= laser_x + 4 && y_pos >= laser_y && y_pos <= laser_y + 10);
    
    always @(*) begin
        if (!video_on) 
		      {R,G,B} = 30'd0;
        else if (is_ship) 
		      {R,G,B} = {10'h000, 10'h3FF, 10'h3FF};
        else if (is_m1 || is_m2 || is_m3) 
		      {R,G,B} = {10'h3FF, 10'h100, 10'h000}; // Màu Cam Đỏ
        else if (is_las) 
		      {R,G,B} = {10'h3FF, 10'h3FF, 10'h000}; // Tia Laser vàng
        else {R,G,B} = 30'd0;
    end
endmodule