`include "femtosoc.v"

`timescale 1 ns / 10 ps

`define SIMU_FLASH // use para pegar as intrunções via readmemh()
`define NRV_RAM 620

module led_blink(
				input en,  
                input  clk,
                output led
                );
   reg [25:0] 			  counter;
   assign led = counter[23];

   initial begin
      counter = 0;
   end

   always @(posedge clk)
     begin
        if (en) counter <= counter + 1;
		else counter <= 0;
     end
endmodule

module flash_spi(
	input clk_led,
	input reset_spi, 
	input spi_mosi, 
	output spi_miso,
	input SS,
	input spi_clk,
	output board_led
	);
	
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
	

	always @(posedge spi_clk) begin
		if (!reset_spi) begin
			cnt_rcv = 32;
			cnt_snd = 0;
		end else
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
		if (mem2 == 32'h00002137) en <= 1;
	end
	
		led_blink 
	  			  my_debug_led(
                  .clk(spi_clk),     
                  .led(board_led), 
				  .en(en)
				  );

`ifdef SIMU_FLASH
	initial
	$readmemh("hex.hex", MEM);
`else	

	always @(posedge reset_spi) begin
		MEM[0] <= 32'h004001B7;
		MEM[1] <= 32'h00002137;
		MEM[2] <= 32'h80010113;
		MEM[3] <= 32'h024000EF;
		MEM[4] <= 32'h00100073;
		MEM[5] <= 32'h00001941;
		MEM[6] <= 32'h73697200;
		MEM[7] <= 32'h01007663;
		MEM[8] <= 32'h0000000F;
		MEM[9] <= 32'h33767205;
		MEM[10] <= 32'h70326932;
		MEM[11] <= 32'h00000030;
		MEM[12] <= 32'h00000517;
		MEM[13] <= 32'h03C50513;
		MEM[14] <= 32'h008000EF;
		MEM[15] <= 32'hFF5FF06F;
		MEM[16] <= 32'h00400113;
		MEM[17] <= 32'h00112023;
		MEM[18] <= 32'h00050393;
		MEM[19] <= 32'h0003C503;
		MEM[20] <= 32'h00050863;
		MEM[21] <= 32'h050000EF;
		MEM[22] <= 32'h00138393;
		MEM[23] <= 32'hFF1FF06F;
		MEM[24] <= 32'h00012083;
		MEM[25] <= 32'h00410113;
		MEM[26] <= 32'h00008067;
		MEM[27] <= 32'h494C4546;
		MEM[28] <= 32'h46204550;
		MEM[29] <= 32'h45525245;
		MEM[30] <= 32'h20415249;
		MEM[31] <= 32'h4353414E;
		MEM[32] <= 32'h4E454D49;
		MEM[33] <= 32'h0A214F54;
		MEM[34] <= 32'h00194100;
		MEM[35] <= 32'h69720000;
		MEM[36] <= 32'h00766373;
		MEM[37] <= 32'h00000F01;
		MEM[38] <= 32'h76720500;
		MEM[39] <= 32'h32693233;
		MEM[40] <= 32'h00003070;
		MEM[41] <= 32'h00A1A423;
		MEM[42] <= 32'h20000293;
		MEM[43] <= 32'h0101A303;
		MEM[44] <= 32'h00537333;
		MEM[45] <= 32'hFE031CE3;
		MEM[46] <= 32'h00008067;
		MEM[47] <= 32'h00001941;
		MEM[48] <= 32'h73697200;
		MEM[49] <= 32'h01007663;
		MEM[50] <= 32'h0000000F;
		MEM[51] <= 32'h33767205;
		MEM[52] <= 32'h70326932;
		MEM[53] <= 32'h00000030;
		MEM[54] <= 32'h00100293;
		MEM[55] <= 32'h01129293;
		MEM[56] <= 32'hFFF28293;
		MEM[57] <= 32'hFE029EE3;
		MEM[58] <= 32'h00008067;
		MEM[59] <= 32'h00001941;
		MEM[60] <= 32'h73697200;
		MEM[61] <= 32'h01007663;
		MEM[62] <= 32'h0000000F;
		MEM[63] <= 32'h33767205;
		MEM[64] <= 32'h70326932;
		MEM[65] <= 32'h00000030;
		MEM[66] <= 32'hFF010113;
		MEM[67] <= 32'h00812423;
		MEM[68] <= 32'h00112623;
		MEM[69] <= 32'h00050413;
		MEM[70] <= 32'h00054503;
		MEM[71] <= 32'h00050A63;
		MEM[72] <= 32'h00140413;
		MEM[73] <= 32'hF81FF0EF;
		MEM[74] <= 32'h00044503;
		MEM[75] <= 32'hFE051AE3;
		MEM[76] <= 32'h00C12083;
		MEM[77] <= 32'h00812403;
		MEM[78] <= 32'h01010113;
		MEM[79] <= 32'h00008067;
		MEM[80] <= 32'hFF010113;
		MEM[81] <= 32'h00812423;
		MEM[82] <= 32'h00112623;
		MEM[83] <= 32'h00050413;
		MEM[84] <= 32'h00054503;
		MEM[85] <= 32'h00050A63;
		MEM[86] <= 32'h00140413;
		MEM[87] <= 32'hF49FF0EF;
		MEM[88] <= 32'h00044503;
		MEM[89] <= 32'hFE051AE3;
		MEM[90] <= 32'h00A00513;
		MEM[91] <= 32'hF39FF0EF;
		MEM[92] <= 32'h00C12083;
		MEM[93] <= 32'h00812403;
		MEM[94] <= 32'h00100513;
		MEM[95] <= 32'h01010113;
		MEM[96] <= 32'h00008067;
		MEM[97] <= 32'hEF010113;
		MEM[98] <= 32'h10912223;
		MEM[99] <= 32'h10112623;
		MEM[100] <= 32'h10812423;
		MEM[101] <= 32'h11212023;
		MEM[102] <= 32'h00050493;
		MEM[103] <= 32'h00055863;
		MEM[104] <= 32'h02D00513;
		MEM[105] <= 32'hF01FF0EF;
		MEM[106] <= 32'h409004B3;
		MEM[107] <= 32'h00010913;
		MEM[108] <= 32'h00090413;
		MEM[109] <= 32'h0200006F;
		MEM[110] <= 32'h4A0000EF;
		MEM[111] <= 32'h00140413;
		MEM[112] <= 32'hFEA40FA3;
		MEM[113] <= 32'h00A00593;
		MEM[114] <= 32'h00048513;
		MEM[115] <= 32'h408000EF;
		MEM[116] <= 32'h00050493;
		MEM[117] <= 32'h00A00593;
		MEM[118] <= 32'h00048513;
		MEM[119] <= 32'hFC049EE3;
		MEM[120] <= 32'hFD240CE3;
		MEM[121] <= 32'hFFF40413;
		MEM[122] <= 32'h00044503;
		MEM[123] <= 32'h03050513;
		MEM[124] <= 32'hEB5FF0EF;
		MEM[125] <= 32'hFF2418E3;
		MEM[126] <= 32'h10C12083;
		MEM[127] <= 32'h10812403;
		MEM[128] <= 32'h10412483;
		MEM[129] <= 32'h10012903;
		MEM[130] <= 32'h11010113;
		MEM[131] <= 32'h00008067;
		MEM[132] <= 32'hFE010113;
		MEM[133] <= 32'h00912A23;
		MEM[134] <= 32'h008204B7;
		MEM[135] <= 32'h00812C23;
		MEM[136] <= 32'h01212823;
		MEM[137] <= 32'h01312623;
		MEM[138] <= 32'h00112E23;
		MEM[139] <= 32'h00050993;
		MEM[140] <= 32'h01C00413;
		MEM[141] <= 32'h47848493;
		MEM[142] <= 32'hFFC00913;
		MEM[143] <= 32'h0089D7B3;
		MEM[144] <= 32'h00F7F793;
		MEM[145] <= 32'h00F487B3;
		MEM[146] <= 32'h0007C503;
		MEM[147] <= 32'hFFC40413;
		MEM[148] <= 32'hE55FF0EF;
		MEM[149] <= 32'hFF2414E3;
		MEM[150] <= 32'h01C12083;
		MEM[151] <= 32'h01812403;
		MEM[152] <= 32'h01412483;
		MEM[153] <= 32'h01012903;
		MEM[154] <= 32'h00C12983;
		MEM[155] <= 32'h02010113;
		MEM[156] <= 32'h00008067;
		MEM[157] <= 32'hFE010113;
		MEM[158] <= 32'hFFF58593;
		MEM[159] <= 32'h00812C23;
		MEM[160] <= 32'h00112E23;
		MEM[161] <= 32'h00912A23;
		MEM[162] <= 32'h01212823;
		MEM[163] <= 32'h01312623;
		MEM[164] <= 32'h00259413;
		MEM[165] <= 32'h02044863;
		MEM[166] <= 32'h00820937;
		MEM[167] <= 32'h00050493;
		MEM[168] <= 32'hFFC00993;
		MEM[169] <= 32'h47890913;
		MEM[170] <= 32'h0084D7B3;
		MEM[171] <= 32'h00F7F793;
		MEM[172] <= 32'h00F907B3;
		MEM[173] <= 32'h0007C503;
		MEM[174] <= 32'hFFC40413;
		MEM[175] <= 32'hDE9FF0EF;
		MEM[176] <= 32'hFF3414E3;
		MEM[177] <= 32'h01C12083;
		MEM[178] <= 32'h01812403;
		MEM[179] <= 32'h01412483;
		MEM[180] <= 32'h01012903;
		MEM[181] <= 32'h00C12983;
		MEM[182] <= 32'h02010113;
		MEM[183] <= 32'h00008067;
		MEM[184] <= 32'hFA010113;
		MEM[185] <= 32'h02812C23;
		MEM[186] <= 32'h04F12A23;
		MEM[187] <= 32'h02112E23;
		MEM[188] <= 32'h02912A23;
		MEM[189] <= 32'h03212823;
		MEM[190] <= 32'h03312623;
		MEM[191] <= 32'h03412423;
		MEM[192] <= 32'h03512223;
		MEM[193] <= 32'h03612023;
		MEM[194] <= 32'h01712E23;
		MEM[195] <= 32'h01812C23;
		MEM[196] <= 32'h01912A23;
		MEM[197] <= 32'h01A12823;
		MEM[198] <= 32'h04B12223;
		MEM[199] <= 32'h04C12423;
		MEM[200] <= 32'h04D12623;
		MEM[201] <= 32'h04E12823;
		MEM[202] <= 32'h05012C23;
		MEM[203] <= 32'h05112E23;
		MEM[204] <= 32'h00050413;
		MEM[205] <= 32'h00054503;
		MEM[206] <= 32'h04410793;
		MEM[207] <= 32'h00F12623;
		MEM[208] <= 32'h06050663;
		MEM[209] <= 32'h008209B7;
		MEM[210] <= 32'h02500913;
		MEM[211] <= 32'h07300A93;
		MEM[212] <= 32'h07800B13;
		MEM[213] <= 32'h06400B93;
		MEM[214] <= 32'h06300C13;
		MEM[215] <= 32'h47898993;
		MEM[216] <= 32'hFFC00A13;
		MEM[217] <= 32'h0280006F;
		MEM[218] <= 32'h00144503;
		MEM[219] <= 32'h00240413;
		MEM[220] <= 32'h09550863;
		MEM[221] <= 32'h0D650863;
		MEM[222] <= 32'h0B750A63;
		MEM[223] <= 32'h07850663;
		MEM[224] <= 32'hD25FF0EF;
		MEM[225] <= 32'h0014C503;
		MEM[226] <= 32'h02050263;
		MEM[227] <= 32'h00140493;
		MEM[228] <= 32'hFD250CE3;
		MEM[229] <= 32'hD11FF0EF;
		MEM[230] <= 32'h00048793;
		MEM[231] <= 32'h00040493;
		MEM[232] <= 32'h0014C503;
		MEM[233] <= 32'h00078413;
		MEM[234] <= 32'hFE0512E3;
		MEM[235] <= 32'h03C12083;
		MEM[236] <= 32'h03812403;
		MEM[237] <= 32'h03412483;
		MEM[238] <= 32'h03012903;
		MEM[239] <= 32'h02C12983;
		MEM[240] <= 32'h02812A03;
		MEM[241] <= 32'h02412A83;
		MEM[242] <= 32'h02012B03;
		MEM[243] <= 32'h01C12B83;
		MEM[244] <= 32'h01812C03;
		MEM[245] <= 32'h01412C83;
		MEM[246] <= 32'h01012D03;
		MEM[247] <= 32'h00000513;
		MEM[248] <= 32'h06010113;
		MEM[249] <= 32'h00008067;
		MEM[250] <= 32'h00C12783;
		MEM[251] <= 32'h0007A503;
		MEM[252] <= 32'h00478793;
		MEM[253] <= 32'h00F12623;
		MEM[254] <= 32'hCADFF0EF;
		MEM[255] <= 32'hF89FF06F;
		MEM[256] <= 32'h00C12783;
		MEM[257] <= 32'h0007AC83;
		MEM[258] <= 32'h00478793;
		MEM[259] <= 32'h00F12623;
		MEM[260] <= 32'h000CC503;
		MEM[261] <= 32'hF60508E3;
		MEM[262] <= 32'h001C8C93;
		MEM[263] <= 32'hC89FF0EF;
		MEM[264] <= 32'h000CC503;
		MEM[265] <= 32'hFE051AE3;
		MEM[266] <= 32'hF5DFF06F;
		MEM[267] <= 32'h00C12783;
		MEM[268] <= 32'h0007A503;
		MEM[269] <= 32'h00478793;
		MEM[270] <= 32'h00F12623;
		MEM[271] <= 32'hD49FF0EF;
		MEM[272] <= 32'hF45FF06F;
		MEM[273] <= 32'h00C12783;
		MEM[274] <= 32'h01C00D13;
		MEM[275] <= 32'h0007AC83;
		MEM[276] <= 32'h00478793;
		MEM[277] <= 32'h00F12623;
		MEM[278] <= 32'h01ACD7B3;
		MEM[279] <= 32'h00F7F793;
		MEM[280] <= 32'h00F987B3;
		MEM[281] <= 32'h0007C503;
		MEM[282] <= 32'hFFCD0D13;
		MEM[283] <= 32'hC39FF0EF;
		MEM[284] <= 32'hFF4D14E3;
		MEM[285] <= 32'hF11FF06F;
		MEM[286] <= 32'h33323130;
		MEM[287] <= 32'h37363534;
		MEM[288] <= 32'h42413938;
		MEM[289] <= 32'h46454443;
		MEM[290] <= 32'h00000000;
		MEM[291] <= 32'h3A434347;
		MEM[292] <= 32'h69532820;
		MEM[293] <= 32'h65766946;
		MEM[294] <= 32'h43434720;
		MEM[295] <= 32'h332E3820;
		MEM[296] <= 32'h322D302E;
		MEM[297] <= 32'h2E303230;
		MEM[298] <= 32'h302E3430;
		MEM[299] <= 32'h2E382029;
		MEM[300] <= 32'h00302E33;
		MEM[301] <= 32'h00001B41;
		MEM[302] <= 32'h73697200;
		MEM[303] <= 32'h01007663;
		MEM[304] <= 32'h00000011;
		MEM[305] <= 32'h72051004;
		MEM[306] <= 32'h69323376;
		MEM[307] <= 32'h00307032;
		MEM[308] <= 32'h00A5E733;
		MEM[309] <= 32'h00377713;
		MEM[310] <= 32'h00050793;
		MEM[311] <= 32'h02070263;
		MEM[312] <= 32'h00060E63;
		MEM[313] <= 32'h00C78633;
		MEM[314] <= 32'h00158593;
		MEM[315] <= 32'hFFF5C703;
		MEM[316] <= 32'h00178793;
		MEM[317] <= 32'hFEE78FA3;
		MEM[318] <= 32'hFEC798E3;
		MEM[319] <= 32'h00008067;
		MEM[320] <= 32'h00300793;
		MEM[321] <= 32'h02C7FE63;
		MEM[322] <= 32'hFFC60893;
		MEM[323] <= 32'hFFC8F893;
		MEM[324] <= 32'h00488893;
		MEM[325] <= 32'h011507B3;
		MEM[326] <= 32'h00058693;
		MEM[327] <= 32'h00050713;
		MEM[328] <= 32'h00468693;
		MEM[329] <= 32'hFFC6A803;
		MEM[330] <= 32'h00470713;
		MEM[331] <= 32'hFF072E23;
		MEM[332] <= 32'hFEE798E3;
		MEM[333] <= 32'h00367613;
		MEM[334] <= 32'h011585B3;
		MEM[335] <= 32'hFA5FF06F;
		MEM[336] <= 32'h00050793;
		MEM[337] <= 32'hF9DFF06F;
		MEM[338] <= 32'h00001B41;
		MEM[339] <= 32'h73697200;
		MEM[340] <= 32'h01007663;
		MEM[341] <= 32'h00000011;
		MEM[342] <= 32'h72051004;
		MEM[343] <= 32'h69323376;
		MEM[344] <= 32'h00307032;
		MEM[345] <= 32'h00820537;
		MEM[346] <= 32'h57050513;
		MEM[347] <= 32'h00008067;
		MEM[348] <= 32'h00000000;
		MEM[349] <= 32'h00001B41;
		MEM[350] <= 32'h73697200;
		MEM[351] <= 32'h01007663;
		MEM[352] <= 32'h00000011;
		MEM[353] <= 32'h72051004;
		MEM[354] <= 32'h69323376;
		MEM[355] <= 32'h00307032;
		MEM[356] <= 32'hC80025F3;
		MEM[357] <= 32'hC0002573;
		MEM[358] <= 32'hC80022F3;
		MEM[359] <= 32'hFE559AE3;
		MEM[360] <= 32'h00008067;
		MEM[361] <= 32'hC82025F3;
		MEM[362] <= 32'hC0202573;
		MEM[363] <= 32'hC82022F3;
		MEM[364] <= 32'hFE559AE3;
		MEM[365] <= 32'h00008067;
		MEM[366] <= 32'h00001941;
		MEM[367] <= 32'h73697200;
		MEM[368] <= 32'h01007663;
		MEM[369] <= 32'h0000000F;
		MEM[370] <= 32'h33767205;
		MEM[371] <= 32'h70326932;
		MEM[372] <= 32'h00000030;
		MEM[373] <= 32'h06054063;
		MEM[374] <= 32'h0605C663;
		MEM[375] <= 32'h00058613;
		MEM[376] <= 32'h00050593;
		MEM[377] <= 32'hFFF00513;
		MEM[378] <= 32'h02060C63;
		MEM[379] <= 32'h00100693;
		MEM[380] <= 32'h00B67A63;
		MEM[381] <= 32'h00C05863;
		MEM[382] <= 32'h00161613;
		MEM[383] <= 32'h00169693;
		MEM[384] <= 32'hFEB66AE3;
		MEM[385] <= 32'h00000513;
		MEM[386] <= 32'h00C5E663;
		MEM[387] <= 32'h40C585B3;
		MEM[388] <= 32'h00D56533;
		MEM[389] <= 32'h0016D693;
		MEM[390] <= 32'h00165613;
		MEM[391] <= 32'hFE0696E3;
		MEM[392] <= 32'h00008067;
		MEM[393] <= 32'h00008293;
		MEM[394] <= 32'hFB5FF0EF;
		MEM[395] <= 32'h00058513;
		MEM[396] <= 32'h00028067;
		MEM[397] <= 32'h40A00533;
		MEM[398] <= 32'h0005D863;
		MEM[399] <= 32'h40B005B3;
		MEM[400] <= 32'hF9DFF06F;
		MEM[401] <= 32'h40B005B3;
		MEM[402] <= 32'h00008293;
		MEM[403] <= 32'hF91FF0EF;
		MEM[404] <= 32'h40A00533;
		MEM[405] <= 32'h00028067;
		MEM[406] <= 32'h00008293;
		MEM[407] <= 32'h0005CA63;
		MEM[408] <= 32'h00054C63;
		MEM[409] <= 32'hF79FF0EF;
		MEM[410] <= 32'h00058513;
		MEM[411] <= 32'h00028067;
		MEM[412] <= 32'h40B005B3;
		MEM[413] <= 32'hFE0558E3;
		MEM[414] <= 32'h40A00533;
		MEM[415] <= 32'hF61FF0EF;
		MEM[416] <= 32'h40B00533;
		MEM[417] <= 32'h00028067;
		MEM[418] <= 32'h00000168;
		MEM[419] <= 32'h00490003;
		MEM[420] <= 32'h01010000;
		MEM[421] <= 32'h000D0EFB;
		MEM[422] <= 32'h01010101;
		MEM[423] <= 32'h01000000;
		MEM[424] <= 32'h2E010000;
		MEM[425] <= 32'h2E2E2F2E;
		MEM[426] <= 32'h2F2E2E2F;
		MEM[427] <= 32'h2E2F2E2E;
		MEM[428] <= 32'h69722F2E;
		MEM[429] <= 32'h2D766373;
		MEM[430] <= 32'h2F636367;
		MEM[431] <= 32'h6762696C;
		MEM[432] <= 32'h632F6363;
		MEM[433] <= 32'h69666E6F;
		MEM[434] <= 32'h69722F67;
		MEM[435] <= 32'h00766373;
		MEM[436] <= 32'h76696400;
		MEM[437] <= 32'h0100532E;
		MEM[438] <= 32'h00000000;
		MEM[439] <= 32'h05D40205;
		MEM[440] <= 32'hC4030082;
		MEM[441] <= 32'h01030100;
		MEM[442] <= 32'h01000409;
		MEM[443] <= 32'h04090403;
		MEM[444] <= 32'h01030100;
		MEM[445] <= 32'h01000409;
		MEM[446] <= 32'h04090103;
		MEM[447] <= 32'h01030100;
		MEM[448] <= 32'h01000409;
		MEM[449] <= 32'h04090103;
		MEM[450] <= 32'h01030100;
		MEM[451] <= 32'h01000409;
		MEM[452] <= 32'h04090203;
		MEM[453] <= 32'h01030100;
		MEM[454] <= 32'h01000409;
		MEM[455] <= 32'h04090103;
		MEM[456] <= 32'h01030100;
		MEM[457] <= 32'h01000409;
		MEM[458] <= 32'h04090203;
		MEM[459] <= 32'h02030100;
		MEM[460] <= 32'h01000409;
		MEM[461] <= 32'h04090103;
		MEM[462] <= 32'h01030100;
		MEM[463] <= 32'h01000409;
		MEM[464] <= 32'h04090203;
		MEM[465] <= 32'h01030100;
		MEM[466] <= 32'h01000409;
		MEM[467] <= 32'h04090103;
		MEM[468] <= 32'h02030100;
		MEM[469] <= 32'h01000409;
		MEM[470] <= 32'h04090503;
		MEM[471] <= 32'h01030100;
		MEM[472] <= 32'h01000409;
		MEM[473] <= 32'h04090103;
		MEM[474] <= 32'h01030100;
		MEM[475] <= 32'h01000409;
		MEM[476] <= 32'h04090503;
		MEM[477] <= 32'h01030100;
		MEM[478] <= 32'h01000409;
		MEM[479] <= 32'h04090103;
		MEM[480] <= 32'h01030100;
		MEM[481] <= 32'h01000409;
		MEM[482] <= 32'h04090203;
		MEM[483] <= 32'h02030100;
		MEM[484] <= 32'h01000409;
		MEM[485] <= 32'h04090103;
		MEM[486] <= 32'h01030100;
		MEM[487] <= 32'h01000409;
		MEM[488] <= 32'h04090103;
		MEM[489] <= 32'h04030100;
		MEM[490] <= 32'h01000409;
		MEM[491] <= 32'h04090103;
		MEM[492] <= 32'h01030100;
		MEM[493] <= 32'h01000409;
		MEM[494] <= 32'h04090203;
		MEM[495] <= 32'h01030100;
		MEM[496] <= 32'h01000409;
		MEM[497] <= 32'h04090103;
		MEM[498] <= 32'h02030100;
		MEM[499] <= 32'h01000409;
		MEM[500] <= 32'h04090103;
		MEM[501] <= 32'h02030100;
		MEM[502] <= 32'h01000409;
		MEM[503] <= 32'h04090103;
		MEM[504] <= 32'h01030100;
		MEM[505] <= 32'h01000409;
		MEM[506] <= 32'h04090103;
		MEM[507] <= 32'h04090100;
		MEM[508] <= 32'h01010000;
		MEM[509] <= 32'h00000022;
		MEM[510] <= 32'h081A0002;
		MEM[511] <= 32'h01040082;
		MEM[512] <= 32'h00820688;
		MEM[513] <= 32'h008205D4;
		MEM[514] <= 32'h00820688;
		MEM[515] <= 32'h00820850;
		MEM[516] <= 32'h00820883;
		MEM[517] <= 32'h00820953;
		MEM[518] <= 32'h11018001;
		MEM[519] <= 32'h11061000;
		MEM[520] <= 32'h03011201;
		MEM[521] <= 32'h250E1B0E;
		MEM[522] <= 32'h0005130E;
		MEM[523] <= 32'h00000000;
		MEM[524] <= 32'h0000001C;
		MEM[525] <= 32'h07F40002;
		MEM[526] <= 32'h00040082;
		MEM[527] <= 32'h00000000;
		MEM[528] <= 32'h008205D4;
		MEM[529] <= 32'h000000B4;
		MEM[530] <= 32'h00000000;
		MEM[531] <= 32'h00000000;
		MEM[532] <= 32'h2E2F2E2E;
		MEM[533] <= 32'h2E2E2F2E;
		MEM[534] <= 32'h2F2E2E2F;
		MEM[535] <= 32'h722F2E2E;
		MEM[536] <= 32'h76637369;
		MEM[537] <= 32'h6363672D;
		MEM[538] <= 32'h62696C2F;
		MEM[539] <= 32'h2F636367;
		MEM[540] <= 32'h666E6F63;
		MEM[541] <= 32'h722F6769;
		MEM[542] <= 32'h76637369;
		MEM[543] <= 32'h7669642F;
		MEM[544] <= 32'h2F00532E;
		MEM[545] <= 32'h61726373;
		MEM[546] <= 32'h2F686374;
		MEM[547] <= 32'h6B6E656A;
		MEM[548] <= 32'h2F736E69;
		MEM[549] <= 32'h6B726F77;
		MEM[550] <= 32'h63617073;
		MEM[551] <= 32'h70742F65;
		MEM[552] <= 32'h72662D70;
		MEM[553] <= 32'h6F646565;
		MEM[554] <= 32'h6F742D6D;
		MEM[555] <= 32'h2F736C6F;
		MEM[556] <= 32'h30707074;
		MEM[557] <= 32'h742D2D33;
		MEM[558] <= 32'h636C6F6F;
		MEM[559] <= 32'h6E696168;
		MEM[560] <= 32'h6C6E6F2D;
		MEM[561] <= 32'h61702D79;
		MEM[562] <= 32'h67616B63;
		MEM[563] <= 32'h732D2D65;
		MEM[564] <= 32'h74617263;
		MEM[565] <= 32'h632D6863;
		MEM[566] <= 32'h74737261;
		MEM[567] <= 32'h2F676E65;
		MEM[568] <= 32'h2F6A626F;
		MEM[569] <= 32'h5F363878;
		MEM[570] <= 32'h6C2D3436;
		MEM[571] <= 32'h78756E69;
		MEM[572] <= 32'h7562752D;
		MEM[573] <= 32'h3175746E;
		MEM[574] <= 32'h75622F34;
		MEM[575] <= 32'h2F646C69;
		MEM[576] <= 32'h63736972;
		MEM[577] <= 32'h6E672D76;
		MEM[578] <= 32'h6F742D75;
		MEM[579] <= 32'h68636C6F;
		MEM[580] <= 32'h2F6E6961;
		MEM[581] <= 32'h6C697562;
		MEM[582] <= 32'h63672D64;
		MEM[583] <= 32'h656E2D63;
		MEM[584] <= 32'h62696C77;
		MEM[585] <= 32'h6174732D;
		MEM[586] <= 32'h2F326567;
		MEM[587] <= 32'h63736972;
		MEM[588] <= 32'h2D343676;
		MEM[589] <= 32'h6E6B6E75;
		MEM[590] <= 32'h2D6E776F;
		MEM[591] <= 32'h2F666C65;
		MEM[592] <= 32'h32337672;
		MEM[593] <= 32'h6C692F69;
		MEM[594] <= 32'h2F323370;
		MEM[595] <= 32'h6762696C;
		MEM[596] <= 32'h47006363;
		MEM[597] <= 32'h4120554E;
		MEM[598] <= 32'h2E322053;
		MEM[599] <= 32'h41003233;
		MEM[600] <= 32'h00000019;
		MEM[601] <= 32'h63736972;
		MEM[602] <= 32'h0F010076;
		MEM[603] <= 32'h05000000;
		MEM[604] <= 32'h32337672;
		MEM[605] <= 32'h30703269;
	end

`endif

endmodule


module testbench;

	// Simulation time: 10000 * 1 us = 10 ms
    localparam DURATION = 4000000;

	reg clk, reset, reset_spi;
	wire led, spi_mosi, spi_miso, spi_cs_n, spi_clk;
	wire board_led;

	reg [2:0] count = 0;
    reg monitor_started = 0;
    reg ok_written = 0;
	reg [255:0] file = "output_test";


	flash_spi FLASH_SPI (clk, reset_spi, spi_mosi, spi_miso, spi_cs_n, spi_clk, board_led);
 
    femtosoc ITA_CORE(
		.RESET(reset),
		.D1(led),
    	.clk(clk),
		.spi_mosi(spi_mosi),
		.spi_miso(spi_miso),
		.spi_cs_n(spi_cs_n),
		.spi_clk(spi_clk)
	);

	initial begin
		file = $fopen(file, "w");
	end
	
	initial begin
		reset_spi <=0;
		#1;
		reset_spi <=1;
	end
	initial begin
		reset <= 0;
		clk <= 0;
		#50;
        reset <= 1'b1;
		reset_spi <= 1'b1;
	end

  // Generate read clock signal (about 12 MHz)
    always begin
        #41.667
        clk = ~clk;
    end

     always @(posedge clk) begin
        if (!monitor_started) begin
            count <= count + 1;
            if (count == 3) begin
                monitor_started <= 1;
                count <= 0;
            end
        end else begin
            if (led && !ok_written) begin
                $fdisplay(file, "OK\n");
                ok_written <= 1;
                monitor_started <= 0;
            end
        end
    end

    initial begin
        $dumpfile("testbench_XD.vcd");
        $dumpvars(0, testbench);
        #(DURATION)
        if (!ok_written)
            $fdisplay(file, "ERROR\n");
        $fclose(file);
        $display("Finished!");
        $finish;
    end

endmodule