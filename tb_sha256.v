module tb_sha256();

reg [31:0] input_data;
reg input_valid;
reg last_word;
reg [4:0] index;
reg clk;
reg rst;
wire [255:0] hash_data;
wire output_valid;
reg [31:0] memory_array [0:23]; // 24 x 32-bit blocks (768 bits total)

// Instantiate the SHA-256 module
sha256 UUT (
    .input_data(input_data),
    .input_valid(input_valid),
    .input_ready(input_ready),
    .last_word(last_word),
    .clk(clk),
    .rst(rst),
    .output_valid(output_valid),
    .hash_data(hash_data)
);

// Clock generation
always #10 clk = ~clk;

// Initial setup
initial begin
    clk = 1'b0;
    last_word = 1'b0;
    input_valid = 1'b1;
    index = 0;
    rst = 1'b1;
    #20;
    rst = 1'b0;

    // Load memory file
    $readmemh("my_file.mem", memory_array);
end

// Feeding input data to the SHA-256 core
always @(posedge clk) begin
    if (input_ready && !last_word) begin
        input_data <= memory_array[index];
        index <= index + 1;
    end
end

// Assert last_word after final block
always @(index) begin
    if (index == 24) // 24 blocks in total
        last_word = 1'b1;
end

always @(posedge clk) begin
    if (output_valid) begin
        $display("Hash Output: %h", hash_data); // Display hash in hexadecimal
    end
end

endmodule
