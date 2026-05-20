module Input_Handler (
    input  wire clk_25MHz,
    input  wire rst_n,
    
    // Nút cứng trên board (Active-Low)
    input  wire key_up, key_down, key_left, key_right,
    
    // Tín hiệu từ PS/2 (Active-High)
    input  wire kb_p1_up, kb_p1_down, kb_p1_left, kb_p1_right, 
    input  wire kb_p2_up, kb_p2_down, kb_p2_left, kb_p2_right,
    
    // Công tắc chọn chế độ
    input  wire sw_p1_mode, 
    input  wire sw_p2_mode, 
    
    // Tín hiệu xuất ra Game Logic (Active-High)
    output wire sys_up, sys_down, sys_left, sys_right, 
    output wire p2_pong_up, p2_pong_down,              
    output wire sys_start, sys_reset
);

    // Dây tín hiệu đã được lọc nhiễu cho nút nhấn vật lý
    wire db_up, db_down, db_left, db_right;

    Button_Debouncer db1 (
        .clk_25MHz(clk_25MHz), 
		  .rst_n(rst_n), 
		  .btn_in(key_up),
		  .btn_out_high(db_up)
    );
    Button_Debouncer db2 (
        .clk_25MHz(clk_25MHz),
		  .rst_n(rst_n), 
		  .btn_in(key_down),
		  .btn_out_high(db_down)
    );
    Button_Debouncer db3 (
        .clk_25MHz(clk_25MHz),
		  .rst_n(rst_n), 
		  .btn_in(key_left), 
		  .btn_out_high(db_left)
    );
    Button_Debouncer db4 (
        .clk_25MHz(clk_25MHz), 
		  .rst_n(rst_n), 
		  .btn_in(key_right),
		  .btn_out_high(db_right)
    );

    // Lựa chọn nguồn điều khiển dựa trên SW mode
    assign sys_up    = sw_p1_mode ? kb_p1_up    : db_up;
    assign sys_down  = sw_p1_mode ? kb_p1_down  : db_down;
    assign sys_left  = sw_p1_mode ? kb_p1_left  : db_left;
    assign sys_right = sw_p1_mode ? kb_p1_right : db_right;

    assign p2_pong_up   = sw_p2_mode ? kb_p2_up   : db_left;
    assign p2_pong_down = sw_p2_mode ? kb_p2_down : db_right;

    // Các phím chức năng hệ thống
    assign sys_start = sys_up;    // Dùng nút Lên/W để Start
    assign sys_reset = sys_down;  // Dùng nút Xuống/S để Reset
    
endmodule