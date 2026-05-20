module Game_Console_Top(
    input  wire        CLOCK_50,
    
    // NÚT NHẤN ĐIỀU KHIỂN
    input  wire [3:0]  KEY,  
    
    // CÔNG TẮC HỆ THỐNG
    input  wire [17:0] SW,   
    
    // GIAO TIẾP NGOẠI VI
    input  wire        PS2_CLK, PS2_DAT,
    output wire        VGA_HS, VGA_VS, VGA_CLK, VGA_BLANK, VGA_SYNC,
    output wire [9:0]  VGA_R, VGA_G, VGA_B,
    output wire [6:0]  HEX0, HEX1,
    output wire [0:0]  LEDG  
);

    // ==========================================
    // 1. KHAI BÁO TÍN HIỆU CƠ BẢN
    // ==========================================
    wire clk_25, v_on, rst_n;
    wire [9:0] x, y;
    wire [3:0] state;
    wire [3:0] cdown_val;
    wire ie, ue, pe;
    wire [2:0] sel_game = SW[2:0];

    assign VGA_CLK   = clk_25;
    assign VGA_BLANK = 1'b1; 
    assign VGA_SYNC  = 1'b0; 

    Clock_Divider cd_inst (
        .CLOCK_50(CLOCK_50), 
        .rst(1'b0), 
        .clk_25MHz(clk_25)
	 );
    VGA_Controller vga_inst (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .h_count(x), 
		  .v_count(y), 
		  .h_sync(VGA_HS), 
		  .v_sync(VGA_VS), 
		  .video_on(v_on)
	 );

    // ==========================================
    // 2. MẠCH RESET CỨNG TỰ ĐỘNG & SW[15]
    // ==========================================
    reg [7:0] por_cnt = 8'd0;
    reg sw15_d;
    always @(posedge clk_25) begin
        sw15_d <= SW[15];
        if (SW[15] != sw15_d)
		      por_cnt <= 8'd0; 
        else if (por_cnt != 8'hFF) 
		  		por_cnt <= por_cnt + 8'd1;
    end
	 
    assign rst_n = (por_cnt == 8'hFF); 

    // ==========================================
    // 3. XỬ LÝ NÚT NHẤN, BÀN PHÍM & CÔNG TẮC
    // ==========================================
    reg sw16_d, sw17_d;
    always @(posedge clk_25) begin
        sw16_d <= SW[16];
        sw17_d <= SW[17];
    end
    wire pulse_menu  = (SW[16] != sw16_d); 
    wire pulse_start = (SW[17] != sw17_d);

    wire kb_p1_u, kb_p1_d, kb_p1_l, kb_p1_r, kb_p1_s;
    wire kb_p2_u, kb_p2_d;
    ps2_keyboard ps2_inst(
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .PS2_CLK(PS2_CLK), 
		  .PS2_DAT(PS2_DAT),
        .p1_up(kb_p1_u), 
		  .p1_down(kb_p1_d), 
		  .p1_left(kb_p1_l), 
		  .p1_right(kb_p1_r), 
		  .p1_space(kb_p1_s),
        .p2_up(kb_p2_u), 
		  .p2_down(kb_p2_d)
    );

    wire db_lf, db_rt, db_up, db_dn;
    Button_Debouncer db3 (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .btn_in(KEY[3]), 
		  .btn_out_high(db_lf)
    );
		  
    Button_Debouncer db2 (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .btn_in(KEY[2]), 
		  .btn_out_high(db_rt)
    );
		  
    Button_Debouncer db1 (
        .clk_25MHz(clk_25), 
        .rst_n(rst_n), 
        .btn_in(KEY[1]), 
        .btn_out_high(db_up)
    );
	 
    Button_Debouncer db0 (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n),
		  .btn_in(KEY[0]), 
		  .btn_out_high(db_dn)
    );
	 
	 wire system_start = pulse_start | sp;

    wire sw_mode = SW[4]; // 1: Bàn phím PS2, 0: Nút nhấn trên KIT
    wire up = sw_mode ? kb_p1_u : db_up;
    wire dn = sw_mode ? kb_p1_d : db_dn;
    wire lf = sw_mode ? kb_p1_l : db_lf;
    wire rt = sw_mode ? kb_p1_r : db_rt;
    wire sp = sw_mode ? kb_p1_s : pulse_start;

    wire p2_u = sw_mode ? kb_p2_u : db_up;
    wire p2_d = sw_mode ? kb_p2_d : db_dn; 

    // ==========================================
    // 4. KHAI BÁO DÂY GAME & MASTER FSM
    // ==========================================
    wire [9:0] r0, g0, b0, r1, g1, b1, r2, g2, b2, r3, g3, b3;
    wire [9:0] r4, g4, b4, r5, g5, b5, r6, g6, b6, mr, mg, mb;
    wire [7:0] sc0, sc1, sc2, sc3, sc4, sc5, sc6;
    wire d0, d1, d2, d3, d4, d5, d6; 

    // Tỉ số 3 ván (Chỉ dùng cho Pong)
    wire [2:0] p_p1_rds, p_p2_rds;
    wire [2:0] p1_rds_master = (sel_game == 3'd0) ? p_p1_rds : 3'd0;
    wire [2:0] p2_rds_master = (sel_game == 3'd0) ? p_p2_rds : 3'd0;
    
    wire current_dead = (sel_game==0)? d0 : (sel_game==1)? d1 : (sel_game==2)? d2 : (sel_game==3)? d3 : (sel_game==4)? d4 : (sel_game==5)? d5 : d6;
	 wire pulse_match_reset;

	 Game_Logic_Master master_inst (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n),
        .sw_start(system_start), 
		  .sw_pause(SW[6]), 
		  .sw_reset(pulse_menu), 
        .is_dead(current_dead),
		  .p1_rds(p1_rds_master), 
		  .p2_rds(p2_rds_master), 
		  .game_sel(sel_game),
        .current_state(state),
		  .count_val(cdown_val), 
        .init_en(ie), 
		  .update_en(ue), 
		  .pause_en(pe),
		  .match_reset(pulse_match_reset)
    );

    // ==========================================
    // 5. MODULES 7 TRÒ CHƠI
    // ==========================================
    
    // G0: PONG
    wire [9:0] p_bx, p_by, p_pL, p_pR;
	 pong_logic g0l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
        .init_en(ie), 
		  .update_en(ue),
		  .sw_2p(SW[5]), 
        .p1_up(up), 
		  .p1_down(dn), 
		  .p2_up(p2_u), 
		  .p2_down(p2_d), 
        
        // CHỈ reset tỷ số khi nhấn nút thoát về MENU chính
        .reset_menu(pulse_menu || pulse_match_reset), 
        
        .ball_x(p_bx),
		  .ball_y(p_by), 
		  .paddle_L_y(p_pL),
		  .paddle_R_y(p_pR), 
        .dead(d0), 
		  .score(sc0), 
        .p1_rounds(p_p1_rds), 
		  .p2_rounds(p_p2_rds)
    );
	 
    pong_display g0d (
		  .x_pos(x), 
		  .y_pos(y), 
		  .ball_x(p_bx), 
		  .ball_y(p_by), 
		  .paddle_L_y(p_pL), 
		  .paddle_R_y(p_pR), 
		  .video_on(v_on), 
		  .current_state(state[1:0]), 
		  .VGA_R(r0), 
		  .VGA_G(g0), 
		  .VGA_B(b0)
    );

    // G1: SNAKE
    wire sn_s, sn_a; 
	 wire [5:0] s_hx; 
	 wire [4:0] s_hy;
	 
    snake_logic g1l (
		  .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue), 
		  .btn_up(up), 
		  .btn_down(dn), 
		  .btn_left(lf),
		  .btn_right(rt), 
		  .pixel_x(x), 
		  .pixel_y(y), 
		  .is_snake(sn_s),
		  .is_apple(sn_a),
		  .dead(d1), 
		  .score(sc1),
		  .head_x(s_hx),
		  .head_y(s_hy)
    );
	 
    snake_display g1d (
		  .video_on(v_on), 
		  .is_snake(sn_s), 
		  .is_apple(sn_a),
		  .x_pos(x), 
		  .y_pos(y), 
		  .head_x(s_hx),
		  .head_y(s_hy), 
		  .current_state(state[1:0]),
		  .VGA_R(r1), 
		  .VGA_G(g1), 
		  .VGA_B(b1)
    );

    // G2: FLAPPY BIRD
    wire [9:0] f_by, f_px, f_py; 
    flappy_bird_logic g2l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue),
		  .btn_up(up|sp),
		  .bird_y(f_by), 
		  .pipe_x(f_px), 
		  .pipe_y(f_py), 
		  .dead(d2), 
		  .score(sc2)
    );
	 
    flappy_bird_display g2d (
        .x_pos(x), 
		  .y_pos(y), 
		  .bird_y(f_by), 
		  .pipe_x(f_px), 
		  .pipe_y(f_py),
		  .video_on(v_on), 
		  .R(r2), 
		  .G(g2), 
		  .B(b2)
    );

    // G3: BREAKOUT
    wire [9:0] b_bx, b_by, b_px; 
	 wire [7:0] b_br;
	 
    breakout_logic g3l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue),
		  .btn_left(lf), 
		  .btn_right(rt),
		  .bx(b_bx), 
		  .by(b_by),
		  .px(b_px), 
		  .bricks(b_br),
		  .dead(d3), 
		  .score(sc3)
    );
		  
    breakout_display g3d (
        .x_pos(x), 
		  .y_pos(y), 
		  .bx(b_bx),
		  .by(b_by),
		  .px(b_px), 
		  .bricks(b_br),
		  .video_on(v_on), 
		  .R(r3), 
		  .G(g3), 
		  .B(b3)
    );

    // G4: DINO
    wire [9:0] d_dy, d_cx;
	 
    dino_logic g4l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue), 
		  .btn_up(up|sp), 
		  .dino_y(d_dy), 
		  .cactus_x(d_cx),
		  .dead(d4), 
		  .score(sc4)
	 );
	 
    dino_display g4d (
        .x_pos(x), 
		  .y_pos(y), 
		  .dino_y(d_dy), 
		  .cactus_x(d_cx), 
		  .video_on(v_on), 
		  .R(r4), 
		  .G(g4),
		  .B(b4)
	 );

    // G5: SPACE INVADERS
    wire [9:0] i_sx, i_lx, i_ly, i_m1x, i_m1y, i_m2x, i_m2y, i_m3x, i_m3y; 
	 wire i_m1a, i_m2a, i_m3a;
	 
    invaders_logic g5l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue), 
		  .btn_left(lf), 
		  .btn_right(rt), 
		  .btn_space(sp), 
		  .btn_up(up),
		  .ship_x(i_sx), 
		  .laser_x(i_lx),
		  .laser_y(i_ly), 
		  .m1_x(i_m1x), 
		  .m1_y(i_m1y), 
		  .m2_x(i_m2x), 
		  .m2_y(i_m2y),
		  .m3_x(i_m3x), 
		  .m3_y(i_m3y),
		  .m1_a(i_m1a),
		  .m2_a(i_m2a), 
		  .m3_a(i_m3a),
		  .dead(d5), 
		  .score(sc5)
    );
		  
    invaders_display g5d (
        .x_pos(x),
		  .y_pos(y),
		  .ship_x(i_sx),
		  .laser_x(i_lx), 
		  .laser_y(i_ly), 
		  .m1_x(i_m1x),
		  .m1_y(i_m1y),
		  .m2_x(i_m2x), 
		  .m2_y(i_m2y),
		  .m3_x(i_m3x), 
		  .m3_y(i_m3y),
		  .m1_a(i_m1a), 
		  .m2_a(i_m2a), 
		  .m3_a(i_m3a), 
		  .video_on(v_on),
		  .R(r5),
		  .G(g5), 
		  .B(b5)
    );

    // G6: FROGGER (ẾCH SANG ĐƯỜNG)
    wire [9:0] fr_x, fr_y, l1_x, l2_x, l3_x, l4_x, l5_x;
    wire f_map_type;
    
    frogger_logic g6l (
        .clk_25MHz(clk_25), 
		  .rst_n(rst_n), 
		  .init_en(ie), 
		  .update_en(ue), 
        .btn_up(up), 
		  .btn_down(dn), 
		  .btn_left(lf),
		  .btn_right(rt), 
        .frog_x(fr_x), 
		  .frog_y(fr_y), 
        .lane1_x(l1_x), 
		  .lane2_x(l2_x), 
		  .lane3_x(l3_x), 
		  .lane4_x(l4_x),
		  .lane5_x(l5_x),
        .map_type(f_map_type), 
        .dead(d6), 
		  .score(sc6)
    );
    
    frogger_display g6d (
        .x_pos(x), 
		  .y_pos(y), 
		  .frog_x(fr_x), 
		  .frog_y(fr_y), 
        .lane1_x(l1_x),
		  .lane2_x(l2_x), 
		  .lane3_x(l3_x), 
		  .lane4_x(l4_x), 
		  .lane5_x(l5_x),
        .map_type(f_map_type), 
        .R(r6), 
		  .G(g6), 
		  .B(b6)
    );
    // ==========================================
    // 6. GIAO DIỆN & UI ĐẾM NGƯỢC, CHỮ NHẤP NHÁY
    // ==========================================
    menu_display m_ui (.x_pos(x), .y_pos(y), .video_on(v_on), .game_select(sel_game), .R(mr), .G(mg), .B(mb));
    
    wire num_on;
    vga_number cdown_num (
        .x_pos(x), 
		  .y_pos(y), 
		  .start_x(10'd310), 
		  .start_y(10'd220), 
		  .digit(cdown_val), 
		  .pixel_on(num_on)
    );

    wire [9:0] tr, tg, tb; 
	 wire t_on;
    reg [24:0] blink_cnt; 
	 always @(posedge clk_25) blink_cnt <= blink_cnt + 1;
	 
    UI_Text_Renderer ui_inst (
        .x(x), 
		  .y(y), 
		  .state(state), 
		  .p1_rds(p1_rds_master), 
		  .p2_rds(p2_rds_master), 
        .sw_2p(SW[5]), 
		  .blink_clk(blink_cnt[24]),
        .text_R(tr), 
		  .text_G(tg), 
		  .text_B(tb), 
		  .text_on(t_on)
    );

    // ==========================================
    // 7. BỘ MUX XUẤT HÌNH ẢNH VGA
    // ==========================================
    reg [9:0] rout, gout, bout;
    
    always @(*) begin
        if (t_on) begin
            {rout, gout, bout} = {tr, tg, tb}; // Chữ luôn nằm lớp trên cùng
        end 
        else if (state == 4'd0) begin 
            {rout, gout, bout} = {mr, mg, mb}; // Menu chờ
        end 
        else begin
            // Mux hình nền game
            case(sel_game)
                3'd0: {rout, gout, bout} = {r0, g0, b0}; 
                3'd1: {rout, gout, bout} = {r1, g1, b1}; 
                3'd2: {rout, gout, bout} = {r2, g2, b2}; 
                3'd3: {rout, gout, bout} = {r3, g3, b3}; 
                3'd4: {rout, gout, bout} = {r4, g4, b4}; 
                3'd5: {rout, gout, bout} = {r5, g5, b5}; 
                3'd6: {rout, gout, bout} = {r6, g6, b6}; 
                default: {rout, gout, bout} = {mr, mg, mb};
            endcase
            
            // Vẽ đè số đếm ngược 3-2-1
            if (state == 4'd2 && num_on && cdown_val > 0) begin
                {rout, gout, bout} = {10'h3FF, 10'h3FF, 10'h3FF}; 
            end
            
            // Hiệu ứng làm tối (Dimming)
            if (state == 4'd4 || state == 4'd2 || state == 4'd1 || state == 4'd5) begin
                rout = rout >> 1; 
					 gout = gout >> 1; 
					 bout = bout >> 1;
            end
        end
    end
    
    assign VGA_R = v_on ? rout : 10'd0;
    assign VGA_G = v_on ? gout : 10'd0;
    assign VGA_B = v_on ? bout : 10'd0;
    
    // ==========================================
    // 8. LED ĐIỂM 2 CHỮ SỐ
    // ==========================================

    reg [7:0] current_score;
    always @(*) begin
        case(sel_game)
            3'd0: current_score = sc0; 
				3'd1: current_score = sc1;
            3'd2: current_score = sc2; 
				3'd3: current_score = sc3;
            3'd4: current_score = sc4; 
				3'd5: current_score = sc5;
            3'd6: current_score = sc6; 
            default: current_score = 8'd0;
        endcase
    end
    
    // Đếm lên 99 bằng mạch chia BCD
    wire [3:0] tens, ones;
    Bin2BCD bcd_inst (
        .bin(current_score), 
		  .tens(tens), 
		  .ones(ones)
	 );
    
    Hex_Display hex_tens (
        .bin(tens), 
		  .seg(HEX1)
	 ); // Hàng chục
    Hex_Display hex_ones (
        .bin(ones), 
		  .seg(HEX0)
	 ); // Hàng đơn vị

endmodule
