library verilog;
use verilog.vl_types.all;
entity VGA_Controller is
    port(
        clk_25MHz       : in     vl_logic;
        rst_n           : in     vl_logic;
        h_count         : out    vl_logic_vector(9 downto 0);
        v_count         : out    vl_logic_vector(9 downto 0);
        h_sync          : out    vl_logic;
        v_sync          : out    vl_logic;
        video_on        : out    vl_logic
    );
end VGA_Controller;
