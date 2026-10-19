module top(
    input wire clk,
    input wire rst,
    input wire shift_en,
    input wire [7:0] pixel_in,
    input wire [7:0] shift_amount,
    input wire signed [7:0] k00, k01, k02, k10, k11, k12, k20, k21, k22,
    output wire [7:0] pixel_out,
    output wire valid_out,
    input abs_en
);

    wire wg_valid;
    wire [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;

    window_gen wg ( .clk(clk), .rst(rst), .shift_en(shift_en), .pixel_in(pixel_in), .valid(wg_valid),
        .p00(p00), .p01(p01), .p02(p02), .p10(p10), .p11(p11), .p12(p12), .p20(p20), .p21(p21), .p22(p22)
    );

    convolution conv ( .clk(clk), .rst(rst), .shift_en(shift_en),  .shift_amount(shift_amount), .valid(wg_valid), .pixel_out(pixel_out), .valid_out(valid_out),
        .p00(p00), .p01(p01), .p02(p02), .p10(p10), .p11(p11), .p12(p12), .p20(p20), .p21(p21), .p22(p22),
        .k00(k00), .k01(k01), .k02(k02), .k10(k10), .k11(k11), .k12(k12), .k20(k20), .k21(k21), .k22(k22),
        .abs_en(abs_en)
    );

endmodule