module Game_Logic_Master(
    input  wire clk_25MHz, rst_n, sw_start, sw_pause, sw_reset,
    input  wire is_dead,                    
    input  wire [2:0] p1_rds, p2_rds,      
    input  wire [2:0] game_sel,            
    output reg  [3:0] current_state, 
    output reg  [3:0] count_val,
	 output reg  match_reset,
    output wire init_en, update_en, pause_en
);
    // Định nghĩa State
    localparam MENU=4'd0, MSG_START=4'd1, COUNTDOWN=4'd2, PLAY=4'd3, PAUSE=4'd4, ROUND_WIN=4'd5, RESULT=4'd6;
    
    reg [3:0] next_state; // Sửa thành [3:0] để khớp với current_state
    reg [24:0] timer;     // 25 triệu cần 25-bit để chứa
    wire tick_1s = (timer == 25'd25_000_000);

    // Chuyển trạng thái (Tách biệt Reset bất đồng bộ và đồng bộ)
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) 
            current_state <= MENU; // Reset cứng ưu tiên số 1
        else if (sw_reset) 
            current_state <= MENU; // Reset mềm ưu tiên số 2
        else 
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            MENU:      next_state = sw_start ? MSG_START : MENU;
            MSG_START: next_state = tick_1s ? COUNTDOWN : MSG_START;
            COUNTDOWN: next_state = (count_val == 4'd0) ? PLAY : COUNTDOWN;
            PLAY: begin
                if (sw_pause) next_state = PAUSE;
                else if (is_dead) begin
                    // Nếu là Pong(0) và chưa đủ 3 ván thì Round Win rồi đấu tiếp
                    if (game_sel == 3'd0 && (p1_rds < 3'd2 && p2_rds < 3'd2)) 
                        next_state = ROUND_WIN;
                    else 
                        next_state = RESULT; // Đủ 3 ván hoặc thua game đơn thì kết thúc
                end
                else next_state = PLAY;
            end
            PAUSE:     next_state = sw_pause ? PAUSE : PLAY;
            ROUND_WIN: next_state = tick_1s ? COUNTDOWN : ROUND_WIN; // Nghỉ 1s rồi đếm tiếp
            RESULT:    begin
                if (sw_reset)      next_state = MENU;      // 1. Gạt SW[16] -> Về Menu
                else if (sw_start) next_state = MSG_START; // 2. Gạt SW[17] -> Bắt đầu chơi lại ngay (Replay)
                else               next_state = RESULT;    // 3. Đứng yên nhấp nháy chờ lệnh
            end
            default:   next_state = MENU;
        endcase
    end

    // Logic đếm số 3-2-1 và thời gian
    always @(posedge clk_25MHz) begin
        if (current_state == COUNTDOWN) begin
            timer <= tick_1s ? 25'd0 : timer + 25'd1;
            if (tick_1s && count_val > 4'd0) count_val <= count_val - 4'd1;
        end else if (current_state == MSG_START || current_state == ROUND_WIN) begin
            timer <= tick_1s ? 25'd0 : timer + 25'd1;
            count_val <= 4'd3;
        end else begin
            timer <= 25'd0;
            count_val <= 4'd3;
        end
    end
	 
	 always @(*) begin
        if (current_state == MENU) 
            match_reset = 1'b1; // Ở thực đơn chính -> Luôn xóa tỉ số
        else if (current_state == RESULT && sw_start) 
            match_reset = 1'b1; // Đang ở màn kết quả mà nhấn Replay -> Kích hoạt xóa tỉ số tức thời
        else 
            match_reset = 1'b0; // Các trạng thái khác giữ nguyên để lưu số round đấu
    end
	 
    assign init_en   = (current_state == MSG_START || current_state == ROUND_WIN);
    assign update_en = (current_state == PLAY);
    assign pause_en  = (current_state == PAUSE);
endmodule