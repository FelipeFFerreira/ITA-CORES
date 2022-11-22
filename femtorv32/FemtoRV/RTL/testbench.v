`include "femtosoc.v"

`define SIMU_FLASH
`define NRV_RAM 12140

`timescale 1 ns / 10 ps

module flash_spi(inout spi_mosi, inout spi_miso, input SS, input spi_clk);
	
	reg [31:0]			MEM[0:`NRV_RAM];
	reg [31:0]			rcv_data_dut;
	wire [31:0] 		word_data_dut;
	reg [5:0]			rcv_bitcount_dut;
	reg [5:0]			snd_bitcount_dut;
	reg [31:0]			cmd_addr_dut;
	reg 				sds;
	wire       			receiving_dut = (rcv_bitcount_dut != 0);
	wire       			sending_dut   = (snd_bitcount_dut != 0);
	assign  			spi_miso  = cmd_addr_dut[31];
   	wire [32 - 1:0] 	addr_dut;
   	assign 				addr_dut = {rcv_data_dut[19:0]};
   	wire [31:0] 		mem2;
   	assign mem2 =  		(receiving_dut != 0) ? 32'hzzzz : 
   						{ MEM[addr_dut[9 - 1:2]] };

	assign word_data_dut = {mem2[7:0], mem2[15:8], mem2[23:16], mem2[31:24]};

	always @(negedge SS) begin
		rcv_bitcount_dut <= 6'd32;
	end
	always @(posedge spi_clk) begin
      if (SS == 0) begin
		if (receiving_dut) begin
			rcv_bitcount_dut <= rcv_bitcount_dut - 6'd1;
			rcv_data_dut <= {rcv_data_dut[30:0], spi_mosi};
			sds = 0;
		end
		else if (rcv_bitcount_dut == 0 && sds == 0) begin
			cmd_addr_dut <= word_data_dut;
			snd_bitcount_dut <= 6'd32;
			sds = 1;
		end
		else if (sending_dut) begin
			snd_bitcount_dut <= snd_bitcount_dut - 6'd1;
			cmd_addr_dut <= {cmd_addr_dut[30:0],1'b1};
			//rcv_data_dut <= {word_data_dut[30:0],MISO};
		end
      end
	end
	
	initial begin
      $readmemh("firmwares/verilog_my_verilog_flash.txt", MEM); 
   end
endmodule

module testbench;

	// Simulation time: 10000 * 1 us = 10 ms
    localparam DURATION = 60000000;

	reg clk;
    reg reset, debug_pin;
	wire spi_mosi, spi_miso, spi_cs_n, spi_clk;

`ifdef SIMU_FLASH
	flash_spi FLASH_SPI (spi_mosi, spi_miso, spi_cs_n, spi_clk);
`endif
`ifndef SIMU_FLASH	
	initial
		$readmemh("firmwares/hello.bram.txt", testbench.ITA_CORE.RAM); 
`endif 

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
		debug_pin <= 1;
		reset <= 0;
		clk <= 0;
		#50;
        reset = 1'b1;
	end

  // Generate read clock signal (about 12 MHz)
    always begin
        #41.667
        clk = ~clk;
    end

    initial begin
        $dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
        #(DURATION)
        $display("Finished!");
        $finish;
    end

endmodule