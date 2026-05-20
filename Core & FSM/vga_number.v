module vga_number(
    input  wire [9:0] x_pos, y_pos,   // Tia quét VGA hiện tại
    input  wire [9:0] start_x, start_y, // Tọa độ góc trên cùng bên trái của chữ số
    input  wire [3:0] digit,          // Chữ số muốn in (0-9)
    output wire       pixel_on        // Bằng 1 nếu tia quét chạm vào nét chữ
);
    // Kích thước 1 chữ số: Rộng 20px, Cao 40px, Độ dày nét 4px
    wire in_box = (x_pos >= start_x && x_pos <= start_x + 10'd20 && y_pos >= start_y && y_pos <= start_y + 10'd40);
    
    // Tọa độ 7 nét vẽ (a, b, c, d, e, f, g)
    wire seg_a = in_box && (y_pos >= start_y && y_pos <= start_y + 4);
    wire seg_b = in_box && (x_pos >= start_x + 16 && x_pos <= start_x + 20 && y_pos >= start_y && y_pos <= start_y + 20);
    wire seg_c = in_box && (x_pos >= start_x + 16 && x_pos <= start_x + 20 && y_pos >= start_y + 20 && y_pos <= start_y + 40);
    wire seg_d = in_box && (y_pos >= start_y + 36 && y_pos <= start_y + 40);
    wire seg_e = in_box && (x_pos >= start_x && x_pos <= start_x + 4 && y_pos >= start_y + 20 && y_pos <= start_y + 40);
    wire seg_f = in_box && (x_pos >= start_x && x_pos <= start_x + 4 && y_pos >= start_y && y_pos <= start_y + 20);
    wire seg_g = in_box && (y_pos >= start_y + 18 && y_pos <= start_y + 22);

    reg draw;
    always @(*) begin
        case(digit)
            4'd0: draw = seg_a | seg_b | seg_c | seg_d | seg_e | seg_f;
            4'd1: draw = seg_b | seg_c;
            4'd2: draw = seg_a | seg_b | seg_g | seg_e | seg_d;
            4'd3: draw = seg_a | seg_b | seg_g | seg_c | seg_d;
            4'd4: draw = seg_f | seg_g | seg_b | seg_c;
            4'd5: draw = seg_a | seg_f | seg_g | seg_c | seg_d;
            4'd6: draw = seg_a | seg_f | seg_e | seg_d | seg_c | seg_g;
            4'd7: draw = seg_a | seg_b | seg_c;
            4'd8: draw = seg_a | seg_b | seg_c | seg_d | seg_e | seg_f | seg_g;
            4'd9: draw = seg_a | seg_b | seg_c | seg_d | seg_f | seg_g;
            default: draw = 1'b0;
        endcase
    end
    assign pixel_on = draw;
endmodule