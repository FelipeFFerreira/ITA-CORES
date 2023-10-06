

`define NRV_RAM 1095

`define RV_DEBUG_ICESUGAR_NANO


`ifdef RV_DEBUG_ICESUGAR_NANO
module led_blink(
				input en,  
                input  clk,
                output led,
				input reset
                );
   reg [25:0] 			  counter;
   assign led = (reset == 1) ? counter[20] : counter[23];

   initial begin
      counter = 0;
   end

   always @(posedge clk)
     begin
        if (en) counter <= counter + 1;
		else counter <= 0;
     end
endmodule

`endif //  `ifdef RV_DEBUG_ICESUGAR_NANO

module flash_spi(
	input clk_led,
	inout spi_mosi, 
	inout spi_miso,
	input SS,
	input spi_clk,
	output board_led,

					output CLK_T,

					output TXD,
					input TXD_T,

					input RESET,
					output reset
	);
	assign TXD = TXD_T;
	assign CLK_T = clk_led;

	reg en = 0;
	reg [7:0] recv_send;
	reg [31:0]			MEM[`NRV_RAM:0];
	reg [31:0]			rcv_data_dut;
	wire [31:0] 		word_data_dut;
	reg [5:0]			cnt_rcv = 32;
	reg [5:0]			cnt_snd = 0;
	reg [31:0]			cmd_addr_dut;
	reg 				sds;
	// wire       			receiving_dut = (rcv_bitcount_dut != 0);
	// wire       			sending_dut   = (snd_bitcount_dut != 0);
	assign  			spi_miso  = cmd_addr_dut[31];
   	wire [32 - 1:0] 	addr_dut;
   	assign 				addr_dut = {rcv_data_dut[19:0]};
   	wire [31:0] 		mem2;
   	assign mem2 =  		(cnt_rcv != 0) ? 32'hzzzz : 
   						{ MEM[addr_dut[17 - 1:2]] };

	assign word_data_dut = {mem2[7:0], mem2[15:8], mem2[23:16], mem2[31:24]};
	
	reg reset_debug;

	always @(posedge spi_clk or negedge reset) begin
		if (!reset) begin
			cnt_rcv <= 32;
			cnt_snd <= 0;
			reset_debug <= 1;
		end else begin
			reset_debug <= 0;
			if (SS == 0) begin
				if (cnt_rcv >= 1 && cnt_snd === 0) begin
					cnt_rcv <= cnt_rcv - 1;
					rcv_data_dut <= {rcv_data_dut[30:0], spi_mosi};
					sds = 0;
			end
			else if (cnt_rcv == 0 && sds == 0) begin
				cmd_addr_dut <= word_data_dut;
				cnt_snd <= 32;
				sds = 1;
			end
			else if (cnt_snd >= 1) begin
				cnt_snd <= cnt_snd - 1;
				cmd_addr_dut <= {cmd_addr_dut[30:0],1'b1};
			end
			end 
			if (cnt_snd == 1) cnt_rcv <= 32;
			if (mem2 == 32'h80010113) en <= 1;
		end
	end
		/* for debugging purposes */
	`ifdef RV_DEBUG_ICESUGAR_NANO
		led_blink 
	  			  my_debug_led(
                  .clk(clk_led),     
                  .led(board_led), 
				  .en(en),
				  .reset(reset_debug)
				  );
`endif

	reg [15:0] reset_cnt = 0;
	assign       reset = &reset_cnt;
   always @(posedge clk_led, posedge RESET) begin
    	if (RESET) begin
	 		reset_cnt <= 0;
      	end else begin
	 		reset_cnt <= reset_cnt + !reset;
      end
   end

	CMD_TEST_INTERFACE_SPI


endmodule