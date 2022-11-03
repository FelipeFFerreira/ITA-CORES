`include "femtosoc.v"

//`timescale 1ns/1ns
`define NRV_RAM 6144 

module flash_spi(inout spi_mosi, inout spi_miso, input SS, input spi_clk);
	
	reg [31:0]	MEM[0:(`NRV_RAM/4)-1];
	reg [31:0]	rcv_data_dut;
	wire [31:0] word_data_dut;
	reg [5:0]	rcv_bitcount_dut;
	reg [5:0]	snd_bitcount_dut;
	reg [31:0]	cmd_addr_dut;
	reg 		sds;
	wire       	receiving_dut = (rcv_bitcount_dut != 0);
	wire       	sending_dut   = (snd_bitcount_dut != 0);
	assign  	spi_miso  = cmd_addr_dut[31];
   	wire [32 - 1:0] addr_dut;
   	assign addr_dut = {rcv_data_dut[19:0]};
   	wire [31:0] mem2;
   	assign mem2 =  (receiving_dut != 0) ? 32'hzzzz : 
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
      $readmemh("riscvtest.hex", MEM); 
   end

   

endmodule


module testbench;
	reg clk;
    reg reset;

	flash_spi FLASH_SPI (spi_mosi, spi_miso, spi_cs_n, spi_clk);

    femtosoc ITA_CORE(
		.RESET(reset),
    	.clk(clk),
		.spi_mosi(spi_mosi),
		.spi_miso(spi_miso),
		.spi_cs_n(spi_cs_n),
		.spi_clk(spi_clk)
	);


	initial begin
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
        #60000 $finish;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
	end

endmodule