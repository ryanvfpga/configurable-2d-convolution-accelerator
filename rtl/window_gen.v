module window_gen(
    input clk,
    input shift_en,
    input rst,
    input wire [7:0] pixel_in;
)


wire [7:0] current_pixel_out;
wire [7:0] l1_pixel_out;
wire [7:0] l2_pixel_out;

linebuffer l1 (.clk(clk), .rst(rst), .shift_en(shift_en), .pixel_in(pixel_in), .pixel_out(l1_pixel_out))
linebuffer l2 (.clk(clk), .rst(rst), .shift_en(shift_en), .pixel_in(l1_pixel_out), .pixel_out(l2_pixel_out))

always @(posedge clk) begin
        if (rst) begin
            current_pixel_out <= 8'b0;
        end else if (shift_en) begin
            current_pixel_out <= pixel_in;
        end
    end


reg [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;

always @(posedge clk)
    if(rst) begin

    end else if(shift_en) begin
        p00 <= current_pixel_out;
        p01 <= p00;
        p02 <= p01;

        p10 <= l1_pixel_out;
        p11 <= p10;
        p12 <= p11;

        p20 <= l2_pixel_out;
        p21 <= p20;
        p22 <= p21;
    end



