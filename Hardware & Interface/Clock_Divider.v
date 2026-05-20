module Clock_Divider(
    input CLOCK_50,
    input rst,
    output reg clk_25MHz,
	 
	 output reg  frame_pulse 
);
    // Chia đôi xung 50MHz thành 25MHz bằng một flip-flop đảo trạng thái
    always @(posedge CLOCK_50 or posedge rst) begin
        if (rst) 
            clk_25MHz <= 1'b0;
        else 
            clk_25MHz <= ~clk_25MHz;
    end
	 
	 // ========================
    // 60Hz pulse (Đếm trên clk_25M để đồng bộ tuyệt đối)
    // ========================
    reg [18:0] counter; // 19 bit là đủ chứa số 416666

    always @(posedge clk_25MHz or posedge rst) begin
        if (rst) begin
            counter     <= 0;
            frame_pulse <= 0;
        end else begin
            if (counter == 19'd416666) begin
                counter     <= 0;
                frame_pulse <= 1'b1;
            end else begin
                counter     <= counter + 1;
                frame_pulse <= 0;
            end
        end
    end

endmodule

    
