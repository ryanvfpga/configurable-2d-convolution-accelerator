module window_gen(
    input wire clk,
    input wire shift_en,
    input wire rst,
    input wire [7:0] pixel_in,
    output wire valid,
    output reg [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22
);

reg [6:0] row_count;
reg [6:0] col_count;


always @(posedge clk) begin
    if(rst) begin
        row_count <= 7'b0;
        col_count <= 7'b0;
    end else if(shift_en) begin
        col_count <= (col_count == 7'd127) ? 7'b0 : col_count + 1'b1;
        row_count <= (col_count == 7'd127) ? row_count + 1'b1 : row_count;
    end
end

wire [7:0] l1_pixel_out;
wire [7:0] l2_pixel_out;

linebuffer l1 (.clk(clk), .rst(rst), .shift_en(shift_en), .pixel_in(pixel_in), .pixel_out(l1_pixel_out));
linebuffer l2 (.clk(clk), .rst(rst), .shift_en(shift_en), .pixel_in(l1_pixel_out), .pixel_out(l2_pixel_out));




always @(posedge clk) begin
    if(rst) begin
        p00 <= 8'b0; p01 <= 8'b0; p02 <= 8'b0;
        p10 <= 8'b0; p11 <= 8'b0; p12 <= 8'b0;
        p20 <= 8'b0; p21 <= 8'b0; p22 <= 8'b0;
    end else if(shift_en) begin
        p00 <= pixel_in;
        p01 <= p00;
        p02 <= p01;

        p10 <= l1_pixel_out;
        p11 <= p10;
        p12 <= p11;

        p20 <= l2_pixel_out;
        p21 <= p20;
        p22 <= p21;
    end
end

// Valid Flag Logic
assign valid = (row_count >= 7'd2) && (col_count >= 7'd2);

endmodule