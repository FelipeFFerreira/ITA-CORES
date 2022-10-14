`include "femtosoc.v"

//`timescale 1ns/1ns

module testbench;

`define NRV_RAM 6144 // default for iCESugar-nano (cannot do more !)

	reg 		clk;
    reg 	    reset; // set to 0 to reset the processor
	reg 		RXD;
    reg [31:0] 	RAM[0:(`NRV_RAM/4)-1];

    femtosoc ITA_CORE(
		.RESET(reset),
    	.pclk(clk),
		.RXD(RXD)
	);

	initial begin
    	$readmemh("riscvtest.hex", testbench.ITA_CORE.RAM); 
	end

	initial begin
		reset = 0;
		clk <= 0;
		RXD <= 0;
		#20;
        reset = 1'b1;

		#250;

		reset = 0;
		clk <= 0;
		RXD <= 1;
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
        #94000 $finish;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);
	end

endmodule