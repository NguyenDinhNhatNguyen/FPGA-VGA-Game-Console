module Test_Pattern(
    input wire [9:0] x_pos,     // Tọa độ X (0 - 799)
    input wire [9:0] y_pos,     // Tọa độ Y (0 - 524)
    input wire video_on,        // Cờ cho phép xuất điểm ảnh
    output reg [9:0] VGA_R,     // Kênh Đỏ (10-bit)
    output reg [9:0] VGA_G,     // Kênh Xanh lá (10-bit)
    output reg [9:0] VGA_B      // Kênh Xanh dương (10-bit)
);

    always @(*) begin
        if (video_on) begin
            // Chia đôi màn hình theo chiều ngang (640 / 2 = 320)
            if (x_pos < 320) begin
                VGA_R = 10'h3FF; // Đỏ tối đa (1111111111 trong hệ nhị phân)
                VGA_G = 10'h000;
                VGA_B = 10'h000;
            end else begin
                VGA_R = 10'h000;
                VGA_G = 10'h000;
                VGA_B = 10'h3FF; // Xanh dương tối đa
            end
        end else begin
            // Bắt buộc tắt màu khi ở vùng Blanking
            VGA_R = 10'h000;
            VGA_G = 10'h000;
            VGA_B = 10'h000;
        end
    end
endmodule