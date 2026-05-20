module snake_display(
    input  wire video_on, 
    input  wire [1:0] current_state, // Giữ để không báo lỗi thiếu dây
    input  wire is_snake, is_apple, 
    input  wire [9:0] x_pos, y_pos, 
    input  wire [5:0] head_x, 
    input  wire [4:0] head_y,
    output reg  [9:0] VGA_R, VGA_G, VGA_B
);
    // Tách tọa độ trong từng ô vuông 16x16 (lấy 4 bit cuối từ 0->15)
    wire [3:0] px_mod16 = x_pos[3:0];
    wire [3:0] py_mod16 = y_pos[3:0];

    // Nhận diện Đầu Rắn
    wire is_head = (x_pos[9:4] == head_x && y_pos[9:4] == head_y) && is_snake;
    
    // Nhận diện Thân Rắn (Phần còn lại)
    wire is_body = is_snake && !is_head;

    // Gọt thân: Bỏ đi 2 pixel viền ngoài cùng, thân chỉ còn cỡ 12x12 pixel
    wire draw_body = is_body && (px_mod16 >= 2 && px_mod16 <= 13) && (py_mod16 >= 2 && py_mod16 <= 13);

    always @(*) begin
        if (!video_on) begin
            {VGA_R, VGA_G, VGA_B} = 30'd0;
        end 
        else begin
            if (is_apple) 
                {VGA_R, VGA_G, VGA_B} = {10'h3FF, 10'h000, 10'h000};     // Táo Đỏ
            else if (is_head) 
                {VGA_R, VGA_G, VGA_B} = {10'h1FF, 10'h3FF, 10'h1FF};     // Đầu: TO FULL Ô, Màu Xanh Nhạt
            else if (draw_body) 
                {VGA_R, VGA_G, VGA_B} = {10'h000, 10'h2FF, 10'h000};     // Thân: NHỎ LẠI, Màu Xanh Đậm
            else 
                {VGA_R, VGA_G, VGA_B} = 30'd0;                           // Nền Đen
        end
    end
endmodule