module sobely_tb;
    reg clk;
    reg rst;
    reg shift_en;
    reg abs_en;
    reg [7:0] pixel_in;
    reg [7:0] shift_amount;

    reg signed [7:0] k00, k01, k02;
    reg signed [7:0] k10, k11, k12;
    reg signed [7:0] k20, k21, k22;

    wire [7:0] pixel_out;
    wire valid_out;

    top uut (
        .clk(clk), .rst(rst), .shift_en(shift_en), .abs_en(abs_en),
        .pixel_in(pixel_in), .shift_amount(shift_amount),
        .k00(k00), .k01(k01), .k02(k02),
        .k10(k10), .k11(k11), .k12(k12),
        .k20(k20), .k21(k21), .k22(k22),
        .pixel_out(pixel_out), .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    reg [7:0] image_in [0:16383]; 
    integer out_file;
    integer i;

    initial begin
        clk = 0; rst = 1; shift_en = 0; pixel_in = 0;
    
        $readmemh("build/input_image.hex", image_in);
        out_file = $fopen("build/output_image.hex", "w");

 
        shift_amount = 0;
        abs_en = 1; 
        k00 = -1; k01 = -2; k02 = -1;
        k10 =  0; k11 =  0; k12 =  0;
        k20 =  1; k21 =  2; k22 =  1;

        #20;
        rst = 0;
        #10;
        shift_en = 1;

        for (i = 0; i < 16384; i = i + 1) begin
            @(posedge clk);
            #1 pixel_in = image_in[i];
        end

        repeat(300) @(posedge clk);
        
        $fclose(out_file);
        $display("Sobel Y Simulation Finished Successfully.");
        $finish;
    end

    always @(posedge clk) begin
        #1;
        if (valid_out) begin
            $fdisplay(out_file, "%02x", pixel_out);
        end
    end

endmodule