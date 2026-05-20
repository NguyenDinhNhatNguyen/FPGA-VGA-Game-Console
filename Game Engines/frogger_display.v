module frogger_display(
    input  wire [9:0] x_pos, y_pos, frog_x, frog_y,
    input  wire [9:0] lane1_x, lane2_x, lane3_x, lane4_x, lane5_x,
    input  wire map_type, 
    input  wire video_on,
    output reg  [9:0] R, G, B
);
    wire is_frog = (x_pos >= frog_x && x_pos < frog_x + 20 && y_pos >= frog_y && y_pos < frog_y + 20);
	 
	 
    
    // HÀM VẼ NHÂN BẢN 4 VẬT THỂ
    function draw_obj;
        input [9:0] xp, lx, w;
        input is_river;
        reg [9:0] o1, o2, o3;
        begin
            o1 = (lx + 10'd160 >= 10'd640) ? lx + 10'd160 - 10'd640 : lx + 10'd160;
            o2 = (lx + 10'd320 >= 10'd640) ? lx + 10'd320 - 10'd640 : lx + 10'd320;
            o3 = (lx + 10'd480 >= 10'd640) ? lx + 10'd480 - 10'd640 : lx + 10'd480;
            if (is_river) begin
                draw_obj = (xp >= lx && xp < lx + w) ||
                           (xp >= o1 && xp < o1 + w) ||
                           (xp >= o2 && xp < o2 + w) ||
                           (xp >= o3 && xp < o3 + w);
            end else begin
                draw_obj = (xp >= lx && xp < lx + 10'd40); // 1 xe
            end
        end
    endfunction

    wire is_l1 = draw_obj(x_pos, lane1_x, 10'd40, 1'b0) && (y_pos >= 380 && y_pos < 410);
    wire is_l5 = draw_obj(x_pos, lane5_x, 10'd40, 1'b0) && (y_pos >= 80 && y_pos < 110);
    
    wire is_l2 = draw_obj(x_pos, lane2_x, map_type ? 10'd80 : 10'd40, map_type) && (y_pos >= 300 && y_pos < 330);
    wire is_l3 = draw_obj(x_pos, lane3_x, 10'd40, map_type)                     && (y_pos >= 220 && y_pos < 250);
    wire is_l4 = draw_obj(x_pos, lane4_x, map_type ? 10'd80 : 10'd40, map_type) && (y_pos >= 140 && y_pos < 170);

	 wire is_fixed_wood_1 = (y_pos >= 265 && y_pos < 285) && (x_pos[7:1] != 7'd0); // chừa khe nhỏ ngăn cách các thanh
    wire is_fixed_wood_2 = (y_pos >= 185 && y_pos < 205) && (x_pos[7:1] != 7'd0);
    wire is_fixed_wood   = map_type && (is_fixed_wood_1 || is_fixed_wood_2);
	 
    wire is_river_zone = map_type && (y_pos >= 130 && y_pos < 330);
    
    wire is_dashed = (x_pos[5] == 1'b1);
    wire line_1_2 = (y_pos >= 350 && y_pos < 354) && is_dashed;
    wire line_2_3 = (y_pos >= 270 && y_pos < 274) && is_dashed && !map_type; 
    wire line_3_4 = (y_pos >= 190 && y_pos < 194) && is_dashed && !map_type; 
    wire line_4_5 = (y_pos >= 110 && y_pos < 114) && is_dashed;
    wire is_yellow_line = line_1_2 || line_2_3 || line_3_4 || line_4_5;

    always @(*) begin
        if (!video_on) 
		      {R, G, B} = 30'd0;
        else if (is_frog)
		      {R, G, B} = {10'h000, 10'h2FF, 10'h000}; 
        else if (is_l1 || is_l5) 
		      {R, G, B} = {10'h3FF, 10'd0, 10'd0}; 
        else if (is_l2 || is_l4) begin
            if (map_type) 
				     {R, G, B} = {10'h2A0, 10'h150, 10'h050}; // Gỗ Nâu
            else {R, G, B} = {10'h3FF, 10'd0, 10'd0};     // Xe Đỏ
        end
        else if (is_l3) begin
            if (map_type) 
				     {R, G, B} = {10'h000, 10'h3FF, 10'h100}; // Sen xanh nhạt
            else {R, G, B} = {10'h3FF, 10'd0, 10'd0};     
        end
		  else if (is_fixed_wood)       
		      {R, G, B} = {10'h1A0, 10'h0D0, 10'h020};
        else if (is_yellow_line)      
		      {R, G, B} = {10'h3FF, 10'h3FF, 10'd0}; 
        else if (is_river_zone)       
		      {R, G, B} = {10'h000, 10'h180, 10'h3FF}; 
        else if (y_pos >= 80 && y_pos <= 410) 
		      {R, G, B} = {10'h120, 10'h120, 10'h120}; 
        else {R, G, B} = {10'h000, 10'h200, 10'h000}; 
    end
endmodule