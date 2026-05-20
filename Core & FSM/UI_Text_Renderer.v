module UI_Text_Renderer(
    input  wire [9:0] x, y,
    input  wire [3:0] state,
    input  wire [2:0] p1_rds, p2_rds,
    input  wire sw_2p, blink_clk,
    output reg  [9:0] text_R, text_G, text_B,
    output wire text_on
);
    // Bộ tạo Font 20x30 cực nhẹ
    function draw_char(input [7:0] char, input [9:0] x0, y0, px, py);
        reg [4:0] dx, dy;
        begin
            dx = px - x0; dy = py - y0;
            if (px >= x0 && px < x0 + 20 && py >= y0 && py < y0 + 30) begin
                case (char)
                    "S": draw_char = (dy<5) || (dy>12 && dy<17) || (dy>25) || (dx<5 && dy<15) || (dx>15 && dy>15);
                    "T": draw_char = (dy<5) || (dx>7 && dx<13);
                    "A": draw_char = (dy<5) || (dx<5) || (dx>15) || (dy>12 && dy<17);
                    "R": draw_char = (dy<5) || (dx<5) || (dx>15 && dy<15) || (dy>12 && dy<17) || (dx>10 && dx<15 && dy>15);
                    "P": draw_char = (dy<5) || (dx<5) || (dx>15 && dy<15) || (dy>12 && dy<17);
                    "U": draw_char = (dx<5) || (dx>15) || (dy>25);
                    "E": draw_char = (dy<5) || (dx<5) || (dy>12 && dy<17) || (dy>25);
                    "W": draw_char = (dx<5) || (dx>15) || (dy>25) || (dx>7 && dx<13 && dy>15);
                    "I": draw_char = (dy<5) || (dy>25) || (dx>7 && dx<13);
                    "N": draw_char = (dx<5) || (dx>15) || (dx>5 && dx<15 && dy>10 && dy<20);
                    "L": draw_char = (dx<5) || (dy>25);
                    "O": draw_char = (dx<5) || (dx>15) || (dy<5) || (dy>25);
                    "1": draw_char = (dx>10 && dx<15) || (dy<5 && dx>5 && dx<15) || (dy>25);
                    "2": draw_char = (dy<5) || (dx>15 && dy<15) || (dy>12 && dy<17) || (dx<5 && dy>15) || (dy>25);
                    default: draw_char = 0;
                endcase
            end else draw_char = 0;
        end
    endfunction

    reg draw;
    always @(*) begin
        draw = 1'b0;
        case (state)
            4'd1: // START
                if (draw_char("S",230,220,x,y) || draw_char("T",260,220,x,y) || draw_char("A",290,220,x,y) || 
                    draw_char("R",320,220,x,y) || draw_char("T",350,220,x,y)) draw = 1'b1;
            4'd4: // PAUSE
                if (draw_char("P",230,220,x,y) || draw_char("A",260,220,x,y) || draw_char("U",290,220,x,y) || 
                    draw_char("S",320,220,x,y) || draw_char("E",350,220,x,y)) draw = 1'b1;
            4'd6: // RESULT
                if (blink_clk) begin
                    if (sw_2p) begin
                        if (p1_rds >= 2) begin // P1 WIN
                            if (draw_char("P",200,220,x,y) || draw_char("1",230,220,x,y) || draw_char("W",270,220,x,y) || 
                                draw_char("I",300,220,x,y) || draw_char("N",330,220,x,y)) draw = 1'b1;
                        end else begin         // P2 WIN
                            if (draw_char("P",200,220,x,y) || draw_char("2",230,220,x,y) || draw_char("W",270,220,x,y) || 
                                draw_char("I",300,220,x,y) || draw_char("N",330,220,x,y)) draw = 1'b1;
                        end
                    end else begin
                        if (p1_rds >= 2) begin // WIN
                            if (draw_char("W",260,220,x,y) || draw_char("I",290,220,x,y) || draw_char("N",320,220,x,y)) draw = 1'b1;
                        end else begin         // LOSE
                            if (draw_char("L",245,220,x,y) || draw_char("O",275,220,x,y) || draw_char("S",305,220,x,y) || 
                                draw_char("E",335,220,x,y)) draw = 1'b1;
                        end
                    end
                end
            default: draw = 1'b0;
        endcase
    end

    assign text_on = draw;

    always @(*) begin
        if (state == 4'd6) begin 
            if (p1_rds >= 3'd2) {text_R, text_G, text_B} = {10'h3FF, 10'h3FF, 10'd0}; // Vàng
            else                {text_R, text_G, text_B} = {10'h3FF, 10'd0, 10'd0};   // Đỏ
        end else {text_R, text_G, text_B} = {10'h3FF, 10'h3FF, 10'h3FF}; // Trắng
    end
endmodule