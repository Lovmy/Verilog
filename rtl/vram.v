
module vram (
  input clk,
  input [15:0] addr_rd,
  input [15:0] addr_wr,
  input [23:0] din,
  output reg [23:0] dout,
  input we
);

reg [23:0] memory[320*200:0];	// 1111 1010 0000 0000

// The hex_memory_file.mem or bin_memory_file.mem file consists of text hex/binary values separated by whitespace:
// space, tab, and newline.

initial
begin
	$display( "Loading rom." );
	// $readmemh( "rom_image.mem", memory );
end

always @(posedge clk)
  if (we) memory[addr_wr] <= din;

always @(posedge clk)
  dout <= memory[addr_rd];
  
endmodule

// RAM avec une seule ligne d'adresse et de donnee __________________________________________________________________________________________

module ram_single #(
	parameter DATA_WIDTH=8,				// width of data bus
	parameter ADDR_WIDTH=8				// width of addresses buses
)
(
	input [(DATA_WIDTH-1):0] data,	// data to be written
	input [(ADDR_WIDTH-1):0] addr,	// address for write/read operation
	input we,								// write enable signal
	input clk,								// clock signal
	output [(DATA_WIDTH-1):0] q		// read data
);

reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
reg [ADDR_WIDTH-1:0] addr_r;

always @(posedge clk)
begin											// WRITE
	if (we)
	begin
		ram[addr] <= data;
	end
	addr_r <= addr;
end

assign q = ram[addr_r];					// READ

endmodule

