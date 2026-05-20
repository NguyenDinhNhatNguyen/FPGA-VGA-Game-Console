module tictactoe_display(
    input  wire [9:0] x_pos, y_pos, 
    input  wire       video_on, 
    input  wire [3:0] cursor, 
    output reg  [1:0] c0, 
	 output reg  [1:0] c1, 
	 output reg  [1:0] c2, 
	 output reg  [1:0] c3, 
	 output reg  [1:0] c4, 
	 output reg  [1:0] c5, 
	 output reg  [1:0] c6, 
	 output reg  [1:0] c7, 
	 output reg  [1:0] c8,  
    output reg  [9:0] R, 
	 output reg  [9:0] G, 
	 output reg  [9:0] B
);
    wire is_board = (x_pos >= 170 && x_pos <= 470 && y_pos >= 90 && y_pos <= 390); 
    wire is_line  = is_board && ((x_pos % 100 < 5) || (y_pos % 100 < 5));
    
    wire [3:0] cur_cell = (x_pos < 170 || x_pos > 470 || y_pos < 90 || y_pos > 390) ? 4'd15 : ((x_pos - 170) / 100) + (((y_pos - 90) / 100) * 3); 
    
    reg [1:0] cell_val;
    always @(*) begin
        case (cur_cell) 
            0: cell_val = c0; 1: cell_val = c1; 2: cell_val = c2; 
            3: cell_val = c3; 4: cell_val = c4; 5: cell_val = c5; 
            6: cell_val = c6; 7: cell_val = c7; 8: cell_val = c8; 
            default: cell_val = 2'd0; 
        endcase
    end
    
    always @(*) begin
        if (!video_on) {R, G, B} = 30'd0; 
        else if (is_line) {R, G, B} = {10'h3FF, 10'h3FF, 10'h3FF}; 
        else if (is_board) begin
            if (cursor == cur_cell) {R, G, B} = {10'h1FF, 10'h1FF, 10'h1FF}; 
            else if (cell_val == 1) {R, G, B} = {10'h3FF, 10'h000, 10'h000}; 
            else if (cell_val == 2) {R, G, B} = {10'h000, 10'h000, 10'h3FF}; 
            else {R, G, B} = 30'd0;
        end else {R, G, B} = 30'd0;
    end
endmodule