module pong_display(
    input  wire [9:0] x_pos,
    input  wire [9:0] y_pos,
    input  wire video_on,
    
    input  wire [9:0] ball_x,
    input  wire [9:0] ball_y,
    input  wire [9:0] paddle_L_y,
    input  wire [9:0] paddle_R_y,
    
    input  wire [1:0] current_state, // Giữ lại chân này để Top module không báo lỗi
    
    output reg  [9:0] VGA_R,
    output reg  [9:0] VGA_G,
    output reg  [9:0] VGA_B
);
    parameter BALL_SIZE  = 10;
    parameter PADDLE_W   = 10; 
    parameter PADDLE_H   = 60;
    parameter PADDLE_L_X = 20;
    parameter PADDLE_R_X = 610;

    wire ball_on     = (x_pos >= ball_x && x_pos < ball_x + BALL_SIZE && y_pos >= ball_y && y_pos < ball_y + BALL_SIZE);
    wire paddle_L_on = (x_pos >= PADDLE_L_X && x_pos < PADDLE_L_X + PADDLE_W && y_pos >= paddle_L_y && y_pos < paddle_L_y + PADDLE_H);
    wire paddle_R_on = (x_pos >= PADDLE_R_X && x_pos < PADDLE_R_X + PADDLE_W && y_pos >= paddle_R_y && y_pos < paddle_R_y + PADDLE_H);

    always @(*) begin
        if (!video_on) begin
            {VGA_R, VGA_G, VGA_B} = 30'd0;
        end 
        else begin
            if (ball_on)
                {VGA_R, VGA_G, VGA_B} = {10'h3FF, 10'h3FF, 10'h000}; // Bóng Vàng
            else if (paddle_L_on || paddle_R_on)
                {VGA_R, VGA_G, VGA_B} = {10'h3FF, 10'h3FF, 10'h3FF}; // Thanh trượt Trắng
            else
                {VGA_R, VGA_G, VGA_B} = 30'd0; // Nền Đen
        end
    end
endmodule