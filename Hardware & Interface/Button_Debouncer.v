module Button_Debouncer #(
    parameter DEBOUNCE_TIME = 19'd500_000 // 20ms @ 25MHz
)(
    input  wire clk_25MHz,
    input  wire rst_n,
    input  wire btn_in,      // Nút nhấn thô (Active-Low từ KIT)
    output reg  btn_out_high // Nút đã lọc (Active-High xuất cho Game)
);
    reg [18:0] count;
    reg sync_0, sync_1;
    reg state_internal; // Trạng thái nội bộ (Active-low giống tín hiệu gốc)
	 
	 
    always @(posedge clk_25MHz or negedge rst_n) begin
        if (!rst_n) begin
            sync_0 <= 1'b1; 
            sync_1 <= 1'b1;
            state_internal <= 1'b1; // Mặc định không nhấn là 1
            btn_out_high <= 1'b0;   // Mặc định xuất ra Game là 0
            count <= 19'd0;
        end else begin
            // 2-Stage Flip-flop chống Metastability
            sync_0 <= btn_in; 
            sync_1 <= sync_0;

            if (sync_1 == state_internal) begin
                count <= 19'd0;
            end else begin
                count <= count + 19'd1;
                if (count >= DEBOUNCE_TIME) begin
                    state_internal <= sync_1;
                    // Đảo ngược logic xuất ra cho Game Logic (1 = Nhấn, 0 = Nhả)
                    btn_out_high <= ~sync_1; 
                    count <= 19'd0;
                end
            end
        end
    end
endmodule


