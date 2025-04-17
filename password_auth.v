module password_auth (
    input wire clk,
    input wire rst,
    input wire [31:0] input_data,
    input wire input_valid,
    input wire last_word, 
    output wire input_ready,
    output wire output_valid,
    output reg [255:0] hash_out,
    output reg match
);

parameter [255:0] stored_hash = 256'h6d1e72ad03ddeb5de891e572e2396f8da015d899ef0e79503152d6010a3fe691;

wire [255:0] hash_data;

// Instantiate SHA-256 module
sha256 sha_inst (
    .input_data(input_data),
    .input_valid(input_valid),
    .input_ready(input_ready),
    .last_word(last_word),
    .clk(clk),
    .rst(rst),
    .output_valid(output_valid),
    .hash_data(hash_data)
);

// Output logic
always @(posedge clk) begin
    if (output_valid) begin
        hash_out <= hash_data;
        match <= (hash_data == stored_hash);
    end
end

endmodule
