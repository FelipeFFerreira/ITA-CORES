`include "femtosoc.v"

//`timescale 1ns/1ns
`define NRV_RAM 6144 

module flash_spi(inout spi_mosi, inout spi_miso, input SS, input spi_clk);
	
	reg [31:0] 	MEM[32'h00020000*4:0];
	
	reg [31:0] rcv_data;
	wire [31:0] word_address;
	wire [31:0] word_data;
	reg [5:0]  rcv_bitcount;
	reg [5:0]  snd_bitcount;
	reg [31:0] cmd_addr;

	assign  spi_miso  = cmd_addr[31];

	wire       receiving = (rcv_bitcount != 0);
	wire       sending   = (snd_bitcount != 0);
	reg sds;
	assign word_address = {{13{1'b0}} ,rcv_data[19:0]};
	assign word_data = {MEM[word_address][7:0], MEM[word_address][15:8], MEM[word_address][23:16], MEM[word_address][31:24]};

	always @(negedge SS) begin
		rcv_bitcount <= 6'd32;
	end
	always @(posedge spi_clk) begin
      if (SS == 0) begin
		if (receiving) begin
			rcv_bitcount <= rcv_bitcount - 6'd1;
			rcv_data <= {rcv_data[30:0], spi_mosi};
			sds = 0;
		end
		else if (rcv_bitcount == 0 && sds == 0) begin
			cmd_addr <= word_data;
			snd_bitcount <= 6'd32;
			sds = 1;
		end
		else if (sending) begin
			snd_bitcount <= snd_bitcount - 6'd1;
			cmd_addr <= {cmd_addr[30:0],1'b1};
			//rcv_data <= {word_data[30:0],MISO};
		end
      end

	end
	
	initial begin
      $readmemh("riscvtest.hex", MEM, 32'h00020000); 
   end

endmodule


module testbench;
	reg clk;
    reg reset;
	reg debug_pin;

	flash_spi FLASH_SPI (spi_mosi, spi_miso, spi_cs_n, spi_clk);

    femtosoc ITA_CORE(
		.RESET(reset),
    	.clk(clk),
		.spi_mosi(spi_mosi),
		.spi_miso(spi_miso),
		.spi_cs_n(spi_cs_n),
		.spi_clk(spi_clk),
		.debug_pin(debug_pin)
	);


	initial begin
		debug_pin <= 0;
		reset <= 0;
		clk <= 0;
		#20;
        reset = 1'b1;
	end

	always begin
        #10 clk = !clk;
    end
    
	// always @(posedge clk) begin
// `ifdef BASE_BOOK_TEST
// 		if (isStore)
// 			if ((mem_ADDR === 100) & (mem_WDATA === 25)) begin
// 				$display("Simulation succeeded");
// 				$display("mem_ADDR = %d | mem_WDATA = %d", mem_ADDR, mem_WDATA);
// 				$stop;
// 			end
// 			else if (mem_ADDR !== 96) begin
// 				//$display("Simulation failed");
// 				//$stop;
// 			end
// `endif
// `ifdef TEST_RV32I
// 		// instr_ax = instr;
// 		// instr_ax = {instr, 2'b11};
//     	// $display("%h", instr_ax); 
// `endif
	// end
	initial
        #5000 $finish;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
	end

endmodule