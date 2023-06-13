/*************************************************************************************/

/**********************************************************************************************************/
                     // UART
/**********************************************************************************************************/
// `include "uart.v"           // The UART (serial port over USB)
`define NRV_FREQ 12            // Validating on icesugar-nano

module buart #(
  parameter FREQ_MHZ = 12,
  parameter BAUDS    = 115200
) (
    input clk,
    input resetq,

    output tx,
    input  rx,

    input  wr,
    input  rd,
    input  [7:0] tx_data,
    output [7:0] rx_data,

    output busy,
    output valid
);

   /************** Baud frequency constants ******************/

    parameter divider = FREQ_MHZ * 1000000 / BAUDS;
    parameter divwidth = $clog2(divider);

    parameter baud_init = divider;
    parameter half_baud_init = divider/2+1;

   /************* Receiver ***********************************/

    // Trick from Olof Kindgren: use n+1 bit and decrement instead of
    // incrementing, and test the sign bit.

    reg [divwidth:0] recv_divcnt;
    wire recv_baud_clk = recv_divcnt[divwidth];

    reg recv_state;
    reg [8:0] recv_pattern;
    reg [7:0] recv_buf_data;
    reg recv_buf_valid;

    assign rx_data = recv_buf_data;
    assign valid = recv_buf_valid;


    always @(posedge clk) begin

       if (rd) recv_buf_valid <= 0;
 
       if (!resetq) recv_buf_valid <= 0;

       case (recv_state)

         0: begin
               if (!rx) begin
                 recv_state <= 1;
		 /* verilator lint_off WIDTH */
                 recv_divcnt <= half_baud_init;
		 /* verilator lint_on WIDTH */
               end
               recv_pattern <= 0;
            end

         1: begin
               if (recv_baud_clk) begin

                 // Inverted start bit shifted through the whole register 
		 // The idea is to use the start bit as marker 
		 // for "reception complete", 
		 // but as initialising registers to 10'b1_11111111_1 
		 // is more costly than using zero, 
		 // it is done with inverted logic. 
                 if (recv_pattern[0]) begin
                   recv_buf_data  <= ~recv_pattern[8:1];
                   recv_buf_valid <= 1;
                   recv_state <= 0;
                 end else begin
                   recv_pattern <= {~rx, recv_pattern[8:1]};
		   /* verilator lint_off WIDTH */		    
                   recv_divcnt <= baud_init;
		   /* verilator lint_on WIDTH */
                 end
               end else recv_divcnt <= recv_divcnt - 1;
            end

       endcase
    end

   /************* Transmitter ******************************/

    reg [divwidth:0] send_divcnt;
    wire send_baud_clk  = send_divcnt[divwidth];

    reg [9:0] send_pattern;
    assign tx = send_pattern[0];
    assign busy = |send_pattern[9:1];

    // The transmitter shifts until the stop bit is on the wire, 
    // and stops shifting then.
    always @(posedge clk) begin
       if (wr) send_pattern <= {1'b1, tx_data[7:0], 1'b0};
       else if (send_baud_clk & busy) send_pattern <= send_pattern >> 1;
       /* verilator lint_off WIDTH */		    
       if (wr | send_baud_clk) send_divcnt <= baud_init;
                          else send_divcnt <= send_divcnt - 1;
       /* verilator lint_on WIDTH */		           
    end

endmodule

module UART(
    input wire 	       clk,      // system clock
    input wire 	       rstrb,    // read strobe		
    input wire 	       wstrb,    // write strobe
    input wire 	       sel_dat,  // select data reg (rw)
    input wire 	       sel_cntl, // select control reg (r) 	       	    
    input wire [31:0]  wdata,    // data to be written
    output wire [31:0] rdata,    // data read

    input wire 	       RXD, // UART pins
    output wire        TXD,

    output reg         brk  // goes high one cycle when <ctrl><C> is pressed. 	    
);

wire [7:0] rx_data;
wire [7:0] tx_data;
wire serial_tx_busy;
wire serial_valid;

buart #(
  .FREQ_MHZ(`NRV_FREQ),
  .BAUDS(115200)
) the_buart (
   .clk(clk),
   .resetq(!brk),
   .tx(TXD),
   .rx(RXD),
   .tx_data(wdata[7:0]),
   .rx_data(rx_data),
   .busy(serial_tx_busy),
   .valid(serial_valid),
   .wr(sel_dat && wstrb),
   .rd(sel_dat && rstrb) 
);

assign rdata =   sel_dat  ? {22'b0, serial_tx_busy, serial_valid, rx_data} 
               : sel_cntl ? {22'b0, serial_tx_busy, serial_valid, 8'b0   } 
               : 32'b0;   

always @(posedge clk) begin
   brk <= serial_valid && (rx_data == 8'd3);
end

endmodule