module flappy_bird_display(
    input  wire [9:0] x_pos, y_pos, bird_y, pipe_x, pipe_y,
    input  wire       video_on,
    output reg  [9:0] R, G, B
);
    // Vẽ chim (Hình vuông màu vàng)
    wire is_bird = (x_pos >= 280 && x_pos <= 310 && y_pos >= bird_y && y_pos <= bird_y + 25);
    
    // Vẽ ống (Màu xanh lá, chừa khoảng hở ở giữa)
    wire is_pipe = (x_pos >= pipe_x && x_pos <= pipe_x + 60) && (y_pos <= pipe_y || y_pos >= pipe_y + 100);

    always @(*) begin
        if (!video_on) {R, G, B} = 30'd0;
        else if (is_bird) 
		      {R, G, B} = {10'h3FF, 10'h3FF, 10'h000}; // Vàng
        else if (is_pipe) 
		      {R, G, B} = {10'd0, 10'h3FF, 10'd0};     // Xanh lá
        else {R, G, B} = {10'd0, 10'd0, 10'h200};                 // Nền xanh dương tối
    end
endmodule