

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
	// always @(posedge spi_clk) begin
	// 	if (MEM[0] == 32'h004001B7 && MEM[605] == 32'h30703269 && MEM[466] == 32'h01000409)
	// 		en <= 1;
	// 	else en <= 0;
	// end
	initial begin
		MEM[0] <= 32'h004001B7;
		MEM[1] <= 32'h00002137;
		MEM[2] <= 32'h80010113;
		MEM[3] <= 32'h060000EF;
		MEM[4] <= 32'h00100073;
		MEM[5] <= 32'h00001941;
		MEM[6] <= 32'h73697200;
		MEM[7] <= 32'h01007663;
		MEM[8] <= 32'h0000000F;
		MEM[9] <= 32'h33767205;
		MEM[10] <= 32'h70326932;
		MEM[11] <= 32'h00000030;
		MEM[12] <= 32'h00400113;
		MEM[13] <= 32'h00112023;
		MEM[14] <= 32'h00050393;
		MEM[15] <= 32'h0003C503;
		MEM[16] <= 32'h00050863;
		MEM[17] <= 32'h098000EF;
		MEM[18] <= 32'h00138393;
		MEM[19] <= 32'hFF1FF06F;
		MEM[20] <= 32'h00012083;
		MEM[21] <= 32'h00410113;
		MEM[22] <= 32'h00008067;
		MEM[23] <= 32'h4154495B;
		MEM[24] <= 32'h4956522D;
		MEM[25] <= 32'h0D5D4154;
		MEM[26] <= 32'h0000000A;
		MEM[27] <= 32'h00001737;
		MEM[28] <= 32'h004046B7;
		MEM[29] <= 32'h00270713;
		MEM[30] <= 32'h00000793;
		MEM[31] <= 32'h00F6A023;
		MEM[32] <= 32'h00000517;
		MEM[33] <= 32'hFDC50513;
		MEM[34] <= 32'hFA9FF0EF;
		MEM[35] <= 32'h00378793;
		MEM[36] <= 32'hFEE796E3;
		MEM[37] <= 32'hFE5FF06F;
		MEM[38] <= 32'h3A434347;
		MEM[39] <= 32'h69532820;
		MEM[40] <= 32'h65766946;
		MEM[41] <= 32'h43434720;
		MEM[42] <= 32'h332E3820;
		MEM[43] <= 32'h322D302E;
		MEM[44] <= 32'h2E303230;
		MEM[45] <= 32'h302E3430;
		MEM[46] <= 32'h2E382029;
		MEM[47] <= 32'h00302E33;
		MEM[48] <= 32'h00001B41;
		MEM[49] <= 32'h73697200;
		MEM[50] <= 32'h01007663;
		MEM[51] <= 32'h00000011;
		MEM[52] <= 32'h72051004;
		MEM[53] <= 32'h69323376;
		MEM[54] <= 32'h00307032;
		MEM[55] <= 32'h00A1A423;
		MEM[56] <= 32'h20000293;
		MEM[57] <= 32'h0101A303;
		MEM[58] <= 32'h00537333;
		MEM[59] <= 32'hFE031CE3;
		MEM[60] <= 32'h00008067;
		MEM[61] <= 32'h00001941;
		MEM[62] <= 32'h73697200;
		MEM[63] <= 32'h01007663;
		MEM[64] <= 32'h0000000F;
		MEM[65] <= 32'h33767205;
		MEM[66] <= 32'h70326932;
	end

endmodule