module linebuffer(
    input [7:0]pixel_in,
    output reg [7:0] pixel_out,
    input rst,
    input clk,
    input shift_en
)

reg [7:0] line_buf_bram [0:126];
reg [6:0] addr_ptr;

always @(posedge clk) begin
    if(rst)
        addr_ptr <= 7'b0;
    else begin
        if(shift_en) begin
            pixel_out <= line_buf_bram[addr_ptr];
            line_buf_bram[addr_ptr] <= pixel_in;
            addr_ptr <= (addr_ptr == 7'd126)?7'b0:addr_ptr + 1'b1;
        end
    end

end



