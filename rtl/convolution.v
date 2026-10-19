module convolution (
    input wire clk,
    input wire rst,
    input wire shift_en,
    input wire [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22,
    input wire signed [7:0] k00, k01, k02, k10, k11, k12, k20, k21, k22,
    output reg [7:0] pixel_out,
    input [7:0] shift_amount,
    input valid,
    output reg valid_out,
    input abs_en
);

    reg v1, v2, v3;

    reg signed [16:0] mul00, mul01, mul02;
    reg signed [16:0] mul10, mul11, mul12;
    reg signed [16:0] mul20, mul21, mul22;

    reg signed [20:0] temp_sum;
    reg signed [18:0] sum_row0, sum_row1, sum_row2;

  
    always @(posedge clk) begin
        if (rst) begin
            mul00 <= 17'sd0; mul01 <= 17'sd0; mul02 <= 17'sd0;
            mul10 <= 17'sd0; mul11 <= 17'sd0; mul12 <= 17'sd0;
            mul20 <= 17'sd0; mul21 <= 17'sd0; mul22 <= 17'sd0;
        
        end else if (shift_en) begin
            mul00 <= $signed({1'b0, p00}) * k00;
            mul01 <= $signed({1'b0, p01}) * k01;
            mul02 <= $signed({1'b0, p02}) * k02;

            mul10 <= $signed({1'b0, p10}) * k10;
            mul11 <= $signed({1'b0, p11}) * k11;
            mul12 <= $signed({1'b0, p12}) * k12;

            mul20 <= $signed({1'b0, p20}) * k20;
            mul21 <= $signed({1'b0, p21}) * k21;
            mul22 <= $signed({1'b0, p22}) * k22;
        end 
    end

 
    always @(posedge clk) begin
        if(rst) begin
            sum_row0 <= 0;
            sum_row1 <= 0;
            sum_row2 <= 0;
            temp_sum <= 0;

        end else if(shift_en) begin
            sum_row0 <= (mul00 + mul01 + mul02);
            sum_row1 <= (mul10 + mul11 + mul12);
            sum_row2 <= (mul20 + mul21 + mul22);
            temp_sum <= (sum_row0 + sum_row1 + sum_row2)  >>> shift_amount;
        end

    end

    reg signed [20:0] abs_sum;
    always @(*) begin
        if(abs_en)
            abs_sum = (temp_sum < 0) ? -temp_sum : temp_sum;
        else
            abs_sum = temp_sum;
    end

    always @(posedge clk) begin
        if(rst) begin
            pixel_out <= 0;
        end else if (shift_en) begin
            if(abs_sum > 21'sd255)
                pixel_out <= 8'd255;
            else
                pixel_out <= abs_sum[7:0];
        end
    end


    always @(posedge clk) begin
        if(rst) begin
            v1 <= 0;
            v2 <= 0;
            v3 <= 0;
        end else if(shift_en) begin
            v1 <= valid;
            v2 <= v1;
            v3 <= v2;
            valid_out <= v3;
        end
    end


endmodule