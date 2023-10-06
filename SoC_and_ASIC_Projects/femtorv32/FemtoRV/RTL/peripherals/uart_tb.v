`include "uart.v"

`timescale 1 ns / 10 ps

module uart_tb();

    // Simulation time: 10000 * 1 us = 10 ms
    localparam DURATION = 10000;
    
    reg  	       clk = 0;         // system clock
    reg  	       rstrb_tb = 0;    // read strobe		
    reg  	       wstrb_tb = 0;    // write strobe
    reg  	       sel_dat_tb = 0;  // select data reg (rw)
    reg  	       sel_cntl_tb = 0; // select control reg (r) 	       	    
    reg  [31:0]    wdata_tb = 0;    // data to be written
    wire [31:0]    rdata_tb = 0;    // data read

    reg 	       RXD_tb = 0; // UART pins
    wire           TXD_tb = 0;

    wire            brk_tb = 0;  // goes high one cycle when <ctrl><C> is pressed. 	    

    
    UART uut (
        .clk(clk),              // system clock
        .rstrb(rstrb_tb),       // read strobe		
        .wstrb(wstrb_tb),       // write strobe
        .sel_dat(sel_dat_tb),   // select data reg (rw)
        .sel_cntl(sel_cntl_tb), // select control reg (r) 	       	    
        .wdata(wdata_tb),       // data to be written
        .rdata(rdata_tb),       // data read

        .RXD(RXD_tb),           // UART pins
        .TXD(TXD_tb),           

        .brk(brk_tb)  // goes high 
    );

    initial begin
        #1500

        sel_dat_tb = 1;
        wstrb_tb = 1;
        wdata_tb <= 32'h4321;
    end
 // Generate read clock signal (about 12 MHz)
    always begin
        #41.667
        clk = ~clk;
    end

    initial begin
    
        // Create simulation output file
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

         // Wait for given amount of time for simulation to complete
        #(DURATION)
        
        // Notify and end simulation
        $display("Finished!");
        $finish;
    end
endmodule