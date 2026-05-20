module VGA_Controller(
    input clk_25MHz,
    input rst_n,
    output reg [9:0] h_count,
    output reg [9:0] v_count,
    output h_sync,
    output v_sync,
    output video_on
);
    // Thông số Timing chuẩn cho VGA 640x480 @ 60Hz
    parameter H_DISPLAY = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_MAX = 800 - 1;
    parameter V_DISPLAY = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33, V_MAX = 525 - 1;

    // Bộ đếm Pixel ngang (h_count) và dòng dọc (v_count)
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_MAX) begin
                h_count <= 10'd0;
                if (v_count == V_MAX) 
                    v_count <= 10'd0;
                else 
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    // Xung đồng bộ tích cực thấp theo chuẩn VGA
    assign h_sync = ~(h_count >= (H_DISPLAY + H_FRONT) && h_count < (H_DISPLAY + H_FRONT + H_SYNC));
    assign v_sync = ~(v_count >= (V_DISPLAY + V_FRONT) && v_count < (V_DISPLAY + V_FRONT + V_SYNC));
    
    // Cờ báo hiệu pixel đang nằm trong vùng có thể hiển thị màu
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
endmodule