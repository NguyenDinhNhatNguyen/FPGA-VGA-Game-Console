module Bin2BCD(
    input  wire [7:0] bin,   // Điểm số 8-bit (0-255)
    output reg  [3:0] tens,  // Hàng chục
    output reg  [3:0] ones   // Hàng đơn vị
);
    always @(*) begin
        // Phép chia trong FPGA tốn tài nguyên, nhưng với số 8-bit thì Quartus tổng hợp vô tư
        tens = bin / 10;
        ones = bin % 10;
    end
endmodule