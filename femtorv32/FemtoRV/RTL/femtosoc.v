// femtorv32, a minimalistic RISC-V RV32I core
//    (minus SYSTEM and FENCE that are not implemented)
//
//       Bruno Levy, May-June 2020
//
// This file: the "System on Chip" that goes with femtorv32.

/*************************************************************************************/

//  `define ASIC

// `default_nettype none // Makes it easier to detect typos !
/*******************************************************************************/
// `include "femtosoc_config.v"        // User configuration of processor and SOC.
// Default femtosoc configuration file for icesugar-nano

/************************* Devices **********************************************************************************/

//`define NRV_IO_LEDS          // Mapped IO, LEDs D1,D2,D3,D4 (D5 is used to display errors)
//`define NRV_IO_IRDA          // In IO_LEDS, support for the IRDA on the IceStick (WIP)
`define NRV_IO_PWM
`define NRV_IO_UART          // Mapped IO, virtual UART (USB)
//`define NRV_IO_SSD1351       // Mapped IO, 128x128x64K OLED screen
//`define NRV_IO_MAX7219       // Mapped IO, 8x8 led matrix
`define NRV_MAPPED_SPI_FLASH // SPI flash mapped in address space. Use with MINIRV32 to run code from SPI flash.

/************************* Processor configuration *******************************************************************/

/*
`define NRV_FEMTORV32_TACHYON       // "Tachyon" (carefully latched for max highfreq). Needs more space (remove MAX7219).
`define NRV_FREQ 60                 // Validated at 60 MHz on the IceStick. Can overclock to 80-95 MHz.
`define NRV_RESET_ADDR 32'h00820000 // Jump execution to SPI Flash (800000h, +128k(20000h) for FPGA bitstream)
`define NRV_COUNTER_WIDTH 24        // Number of bits in cycles counter
`define NRV_TWOLEVEL_SHIFTER        // Faster shifts
// tinyraytracer: 90 MHz, 14:02
//                95 MHz, 13:18
*/


`define NRV_FEMTORV32_QUARK
`define NRV_FREQ 12                 // Validating on icesugar-nano
`define NRV_RESET_ADDR 32'h00820000 // Jump execution to SPI Flash (800000h, +128k(20000h) for FPGA bitstream)
`define NRV_COUNTER_WIDTH 24        // Number of bits in cycles counter
`define NRV_TWOLEVEL_SHIFTER        // Faster shifts
// tinyraytracer: 70 MHz, 17:30 


/************************* RAM (in bytes, needs to be a multiple of 4)***********************************************/

`define NRV_RAM 6144 // default for iCESugar-nano (cannot do more !)

/************************* Advanced devices configuration ***********************************************************/

`define NRV_RUN_FROM_SPI_FLASH // Do not 'readmemh()' firmware from '.hex' file
`define NRV_IO_HARDWARE_CONFIG // Comment-out to disable hardware config registers mapped in IO-Space
                               // (note: firmware libfemtorv32 depends on it)

/********************************************************************************************************************/

`define NRV_CONFIGURED

// `define RV_DEBUG_ICESUGAR_NANO  // so far, it blinks the onboard yellow LED (v1.2 of icesugar nano hw)
/*******************************************************************************/

/*******************************************************************************/
`ifdef NRV_MAPPED_SPI_FLASH
`define NRV_SPI_FLASH
`endif
/*******************************************************************************/

//`include "PLL/femtopll.v"           // The PLL (generates clock at NRV_FREQ)

// `include "DEVICES/uart.v"           // The UART (serial port over USB)
// `include "DEVICES/SSD1351_1331.v"   // The OLED display
// `include "DEVICES/MappedSPIFlash.v" // Idem, but mapped in memory
// `include "DEVICES/MAX7219.v"        // 8x8 led matrix driven by a MAX7219 chip
// `include "DEVICES/LEDs.v"           // Driver for 4 leds
// `include "DEVICES/SDCard.v"         // Driver for SDCard (just for bitbanging for now)
// `include "DEVICES/Buttons.v"        // Driver for the buttons
// `include "DEVICES/FGA.v"            // Femto Graphic Adapter
// `include "DEVICES/HardwareConfig.v" // Constant registers to query hardware config.

// The Ice40UP5K has ample quantities (128 KB) of single-ported RAM that can be
// used as system RAM (but cannot be inferred, uses a special block).
`ifdef ICE40UP5K_SPRAM
// `include "DEVICES/ice40up5k_spram.v"
`endif


/*************************************************************************************/

`ifndef NRV_RESET_ADDR
 `define NRV_RESET_ADDR 0
`endif

`ifndef NRV_ADDR_WIDTH
 `define NRV_ADDR_WIDTH 24
`endif

/*************************************************************************************/

`ifdef RV_DEBUG_ICESUGAR_NANO
module led_blink(  
                input  clk,
                output led
                );
   reg [25:0] 			  counter;
   assign led = ~counter[23];

   initial begin
      counter = 0;
   end

   always @(posedge clk)
     begin
        counter <= counter + 1;
     end
endmodule
`endif //  `ifdef RV_DEBUG_ICESUGAR_NANO

`ifdef NRV_IO_PWM
module pwm #(

    // Parameters
    parameter       WIDTH = 12  // Default PWM values 0..4095

) (

    // Inputs
    input	    reset,
    input           clk,
    input           wstrb,  // Write strobe
    input           sel,    // Select (read/write ignored if low)
    input   [31:0]  wdata,  // Data to be written (to driver)
    
    // Outputs
    output     led
);

    // Internal storage elements
    reg             pwm_led;
    reg [WIDTH-1:0] pwm_count;
    reg [WIDTH-1:0] count;
    
    // Only control the first LED
    assign led = pwm_led;
    
    // Update PWM duty cycle 
    always @ (posedge clk) begin
    	if (!reset) begin
	    pwm_led <= 1'b0;
	    pwm_count <= 0;
	    count <= 0;
	end else
        // If sel is high, record duty cycle count on strobe
        if (sel && wstrb) begin
            pwm_count <= wdata[WIDTH-1:0];
            count <= 0;
            
        // Otherwise, continuously count and flash LED as necessary
        end else begin
            count <= count + 1;
            if (count < pwm_count) begin
                pwm_led <= 1'b1;
            end else begin
                pwm_led <= 1'b0;
            end
        end
    end
    
endmodule
`endif 

/*************************************************************************************/
module FemtoRV32(
   input 	     clk,

   output [31:0] mem_addr,  // address bus
   output [31:0] mem_wdata, // data to be written
   output [3:0]  mem_wmask, // write mask for the 4 bytes of each word
   input  [31:0] mem_rdata, // input lines for both data and instr
   output 	     mem_rstrb, // active to initiate memory read (used by IO)
   input 	     mem_rbusy, // asserted if memory is busy reading value
   input 	     mem_wbusy, // asserted if memory is busy writing value

   input 	     reset      // set to 0 to reset the processor
);


`ifdef NRV_COUNTER_WIDTH
   reg [`NRV_COUNTER_WIDTH-1:0]  cycles;   
`else   
   reg [31:0]  cycles;
`endif  
/***************************************************************************/
   // Program counter and branch target computation.
   /***************************************************************************/
   parameter ADDR_WIDTH       = 24;           
   reg  [ADDR_WIDTH-1:0] PC; // The program counter.
   reg  [31:2] instr;        // Latched instruction. Note that bits 0 and 1 are
                             // ignored (not used in RV32I base instr set).

   parameter RESET_ADDR       = 32'h00000000; 


   localparam ADDR_PAD = {(32-ADDR_WIDTH){1'b0}}; // 32-bits padding for addrs


/*************************************************************************/
   // And, last but not least, the state machine.
   /*************************************************************************/

   localparam FETCH_INSTR_bit     = 0;
   localparam WAIT_INSTR_bit      = 1;
   localparam EXECUTE_bit         = 2;
   localparam WAIT_ALU_OR_MEM_bit = 3;
   localparam NB_STATES           = 4;

   localparam FETCH_INSTR     = 1 << FETCH_INSTR_bit;
   localparam WAIT_INSTR      = 1 << WAIT_INSTR_bit;
   localparam EXECUTE         = 1 << EXECUTE_bit;
   localparam WAIT_ALU_OR_MEM = 1 << WAIT_ALU_OR_MEM_bit;
   
   
   reg [NB_STATES-1:0] state;

  /***************************************************************************/
   // The register file.
   /***************************************************************************/
   
   reg [31:0] rs1;
   reg [31:0] rs2;
   reg [31:0] registerFile [31:0];

////////////////
// The destination register
	wire [4:0] 	  rdId = instr[11:7];

	// The ALU function, decoded in 1-hot form (doing so reduces LUT count)
	// It is used as follows: funct3Is[val] <=> funct3 == val

	wire [7:0] 	  funct3Is = 8'b00000001 << instr[14:12];

	// The five immediate formats, see RiscV reference (link above), Fig. 2.4 p. 12
	wire [31:0]   Uimm = {    instr[31],   instr[30:12], {12{1'b0}}};
	wire [31:0]   Iimm = {{21{instr[31]}}, instr[30:20]};
	/* verilator lint_off UNUSED */ // MSBs of SBJimms are not used by addr adder. 
	wire [31:0]   Simm = {{21{instr[31]}}, instr[30:25],instr[11:7]};
	wire [31:0]   Bimm = {{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
	wire [31:0]   Jimm = {{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};
	/* verilator lint_on UNUSED */

   // Base RISC-V (RV32I) has only 10 different instructions !
   wire isLoad    =  (instr[6:2] == 5'b00000); // rd <- mem[rs1+Iimm]
   wire isALUimm  =  (instr[6:2] == 5'b00100); // rd <- rs1 OP Iimm
   wire isAUIPC   =  (instr[6:2] == 5'b00101); // rd <- PC + Uimm
   wire isStore   =  (instr[6:2] == 5'b01000); // mem[rs1+Simm] <- rs2
   wire isALUreg  =  (instr[6:2] == 5'b01100); // rd <- rs1 OP rs2
   wire isLUI     =  (instr[6:2] == 5'b01101); // rd <- Uimm
   wire isBranch  =  (instr[6:2] == 5'b11000); // if(rs1 OP rs2) PC<-PC+Bimm
   wire isJALR    =  (instr[6:2] == 5'b11001); // rd <- PC+4; PC<-rs1+Iimm
   wire isJAL     =  (instr[6:2] == 5'b11011); // rd <- PC+4; PC<-PC+Jimm
   wire isSYSTEM  =  (instr[6:2] == 5'b11100); // rd <- cycles

   wire isALU = isALUimm | isALUreg;


   // First ALU source, always rs1
   wire [31:0] aluIn1 = rs1;

   // Second ALU source, depends on opcode:
   //    ALUreg, Branch:     rs2
   //    ALUimm, Load, JALR: Iimm
   wire [31:0] aluIn2 = isALUreg | isBranch ? rs2 : Iimm;

   reg  [31:0] aluReg;       // The internal register of the ALU, used by shift.
   reg  [4:0]  aluShamt;     // Current shift amount.

   wire aluBusy = |aluShamt; // ALU is busy if shift amount is non-zero.
   wire aluWr;               // ALU write strobe, starts shifting.

   // The adder is used by both arithmetic instructions and JALR.
   wire [31:0] aluPlus = aluIn1 + aluIn2;


   // Use a single 33 bits subtract to do subtraction and all comparisons
   // (trick borrowed from swapforth/J1)
   wire [32:0] aluMinus = {1'b1, ~aluIn2} + {1'b0,aluIn1} + 33'b1;
   wire        LT  = (aluIn1[31] ^ aluIn2[31]) ? aluIn1[31] : aluMinus[32];
   wire        LTU = aluMinus[32];
   wire        EQ  = (aluMinus[31:0] == 0);


 // A separate adder to compute the destination of load/store.
   // testing instr[5] is equivalent to testing isStore in this context.
   wire [ADDR_WIDTH-1:0] loadstore_addr = rs1[ADDR_WIDTH-1:0] + 
		   (instr[5] ? Simm[ADDR_WIDTH-1:0] : Iimm[ADDR_WIDTH-1:0]);

   assign mem_addr = {ADDR_PAD, 
		       state[WAIT_INSTR_bit] | state[FETCH_INSTR_bit] ? 
		       PC : loadstore_addr
		     };

wire [15:0] LOAD_halfword = loadstore_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];
wire  [7:0] LOAD_byte = loadstore_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0];

wire mem_byteAccess     = instr[13:12] == 2'b00; // funct3[1:0] == 2'b00;
wire mem_halfwordAccess = instr[13:12] == 2'b01; // funct3[1:0] == 2'b01;

wire LOAD_sign = !instr[14] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]);

   wire [31:0] LOAD_data =
         mem_byteAccess ? {{24{LOAD_sign}},     LOAD_byte} :
     mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} :
                          mem_rdata ;

   assign mem_wdata[ 7: 0] = rs2[7:0];
   assign mem_wdata[15: 8] = loadstore_addr[0] ? rs2[7:0]  : rs2[15: 8];
   assign mem_wdata[23:16] = loadstore_addr[1] ? rs2[7:0]  : rs2[23:16];
   assign mem_wdata[31:24] = loadstore_addr[0] ? rs2[7:0]  : 
			     loadstore_addr[1] ? rs2[15:8] : rs2[31:24];

 wire funct3IsShift = funct3Is[1] | funct3Is[5];
 wire [31:0] aluOut =
     (funct3Is[0]  ? instr[30] & instr[5] ? aluMinus[31:0] : aluPlus : 32'b0) | 
     (funct3Is[2]  ? {31'b0, LT}                                     : 32'b0) | 
     (funct3Is[3]  ? {31'b0, LTU}                                    : 32'b0) | 
     (funct3Is[4]  ? aluIn1 ^ aluIn2                                 : 32'b0) | 
     (funct3Is[6]  ? aluIn1 | aluIn2                                 : 32'b0) | 
     (funct3Is[7]  ? aluIn1 & aluIn2                                 : 32'b0) | 
     (funct3IsShift ? aluReg                                         : 32'b0) ; 


wire [ADDR_WIDTH-1:0] PCplusImm = PC + ( instr[3] ? Jimm[ADDR_WIDTH-1:0] : 
					    instr[4] ? Uimm[ADDR_WIDTH-1:0] : 
					               Bimm[ADDR_WIDTH-1:0] );

   wire [ADDR_WIDTH-1:0] PCplus4 = PC + 4;
wire writeBack = ~(isBranch | isStore ) & 
	            (state[EXECUTE_bit] | state[WAIT_ALU_OR_MEM_bit]);

   wire [31:0] writeBackData  =
      /* verilator lint_off WIDTH */	       	       
      (isSYSTEM            ? cycles               : 32'b0) |  // SYSTEM
      /* verilator lint_on WIDTH */	       	       	       
      (isLUI               ? Uimm                 : 32'b0) |  // LUI
      (isALU               ? aluOut               : 32'b0) |  // ALUreg, ALUimm
      (isAUIPC             ? {ADDR_PAD,PCplusImm} : 32'b0) |  // AUIPC
      (isJALR   | isJAL    ? {ADDR_PAD,PCplus4  } : 32'b0) |  // JAL, JALR
      (isLoad              ? LOAD_data            : 32'b0);   // Load
 
   always @(posedge clk) begin
     if (!reset) begin 
         registerFile[0] <= 32'h00000000;
     end
     else if (writeBack)
       if (rdId != 0)
         registerFile[rdId] <= writeBackData;
   end

 always @(posedge clk) begin
      if (!reset) aluShamt <= 0; 
      else if(aluWr) begin
         if (funct3IsShift) begin  // SLL, SRA, SRL
	         aluReg <= aluIn1;
	         aluShamt <= aluIn2[4:0];
	      end
      end 

`ifdef NRV_TWOLEVEL_SHIFTER
      else if(|aluShamt[3:2]) begin // Shift by 4
         aluShamt <= aluShamt - 4;
	 aluReg <= funct3Is[1] ? aluReg << 4 : 
		   {{4{instr[30] & aluReg[31]}}, aluReg[31:4]};	    
      end  else
`endif

      if (|aluShamt) begin
         aluShamt <= aluShamt - 1;
	 aluReg <= funct3Is[1] ? aluReg << 1 :              // SLL
		   {instr[30] & aluReg[31], aluReg[31:1]};  // SRA,SRL
      end
   end

   wire predicate =
        funct3Is[0] &  EQ  | // BEQ
        funct3Is[1] & !EQ  | // BNE
        funct3Is[4] &  LT  | // BLT
        funct3Is[5] & !LT  | // BGE
        funct3Is[6] &  LTU | // BLTU
        funct3Is[7] & !LTU ; // BGEU

   wire [3:0] STORE_wmask =
	      mem_byteAccess      ? 
	            (loadstore_addr[1] ? 
		          (loadstore_addr[0] ? 4'b1000 : 4'b0100) :
		          (loadstore_addr[0] ? 4'b0010 : 4'b0001) 
                    ) :
	      mem_halfwordAccess ? 
	            (loadstore_addr[1] ? 4'b1100 : 4'b0011) :
              4'b1111;


   // The memory-read signal.
   assign mem_rstrb = state[EXECUTE_bit] & isLoad | state[FETCH_INSTR_bit];

   // The mask for memory-write.
   assign mem_wmask = {4{state[EXECUTE_bit] & isStore}} & STORE_wmask;

   // aluWr starts computation (shifts) in the ALU.
   assign aluWr = state[EXECUTE_bit] & isALU;

   wire jumpToPCplusImm = isJAL | (isBranch & predicate);
`ifdef NRV_IS_IO_ADDR  
   wire needToWait = isLoad | 
		     isStore  & `NRV_IS_IO_ADDR(mem_addr) | 
		     isALU & funct3IsShift;
`else
   wire needToWait = isLoad | isStore | isALU & funct3IsShift;   
`endif
   
   always @(posedge clk) begin
      if (!reset) begin
         state      <= WAIT_ALU_OR_MEM; // Just waiting for !mem_wbusy
         PC         <= RESET_ADDR[ADDR_WIDTH-1:0];
      end else

      // See note [1] at the end of this file.
      (* parallel_case *)
      case(1'b1)

        state[WAIT_INSTR_bit]: begin
           if(!mem_rbusy) begin // may be high when executing from SPI flash
              rs1 <= registerFile[mem_rdata[19:15]];
              rs2 <= registerFile[mem_rdata[24:20]];
              instr <= mem_rdata[31:2]; // Bits 0 and 1 are ignored (see
              state <= EXECUTE;         // also the declaration of instr).
           end
        end

        state[EXECUTE_bit]: begin
           PC <= isJALR          ? {aluPlus[ADDR_WIDTH-1:1],1'b0} :
                 jumpToPCplusImm ? PCplusImm :
                 PCplus4;
	   state <= needToWait ? WAIT_ALU_OR_MEM : FETCH_INSTR;
        end

        state[WAIT_ALU_OR_MEM_bit]: begin
           if(!aluBusy & !mem_rbusy & !mem_wbusy) state <= FETCH_INSTR;
        end

        default: begin // FETCH_INSTR
          state <= WAIT_INSTR;
        end
	
      endcase
   end

   

   always @(posedge clk) begin
      if (!reset) begin 
         cycles <= 0;
      end
      else cycles <= cycles + 1;
   end

`ifndef BENCH
   initial begin
      cycles = 0;
      aluShamt = 0;
      registerFile[0] = 0;
   end
`endif

endmodule

module HardwareConfig(
    input wire 	       clk, 
    input wire 	       sel_memory,  // available RAM
    input wire 	       sel_devices, // configured devices 
    input wire         sel_cpuinfo, // CPU information 	      
    output wire [31:0] rdata        // read data
);

// `include "HardwareConfig_bits.v"
localparam IO_LEDS_bit                    = 0;  // RW four leds
localparam IO_UART_DAT_bit                = 1;  // RW write: data to send (8 bits) read: received data (8 bits)
localparam IO_UART_CNTL_bit               = 2;  // R  status. bit 8: valid read data. bit 9: busy sending   
localparam IO_MAPPED_SPI_FLASH_bit        = 20;  // no register (just there to indicate presence)
localparam IO_PWM_bit                     = 12;

`ifdef NRV_COUNTER_WIDTH
   localparam counter_width = `NRV_COUNTER_WIDTH;
`else
   localparam counter_width = 32;
`endif 

localparam NRV_DEVICES = 0

`ifdef NRV_IO_LEDS
   | (1 << IO_LEDS_bit)			 
`endif		    
`ifdef NRV_IO_UART
   | (1 << IO_UART_DAT_bit) | (1 << IO_UART_CNTL_bit)
`endif			    			    
`ifdef NRV_MAPPED_SPI_FLASH
   | (1 << IO_MAPPED_SPI_FLASH_bit)
`endif			    	 
;
   
   assign rdata = sel_memory  ? `NRV_RAM  :
		  sel_devices ?  NRV_DEVICES :
                  sel_cpuinfo ? (`NRV_FREQ << 16) | counter_width : 32'b0;
   
endmodule



// `include "MappedSPIFlash.v" // Idem, but mapped in memory
`ifndef SPI_FLASH_CONFIGURED // Default: using slowest / simplest mode (command $03)
 `define SPI_FLASH_READ
`endif

/********************************************************************************************************************************/

`ifdef SPI_FLASH_READ
module MappedSPIFlash( 
    input wire 	       clk,          // system clock
    input wire reset,
    input wire 	       rstrb,        // read strobe		
    input wire [19:0]  word_address, // address of the word to be read

    output wire [31:0] rdata,        // data read
    output wire        rbusy,        // asserted if busy receiving data			    

		             // SPI flash pins
    output wire        CLK,  // clock
    output reg         CS_N, // chip select negated (active low)		
    output wire        MOSI, // master out slave in (data to be sent to flash)
    input  wire        MISO  // master in slave out (data received from flash)
);

   reg [5:0]  snd_bitcount;
   reg [31:0] cmd_addr;
   reg [5:0]  rcv_bitcount;
   reg [31:0] rcv_data;
   wire       sending   = (snd_bitcount != 0);
   wire       receiving = (rcv_bitcount != 0);
   wire       busy = sending | receiving;
   assign     rbusy = !CS_N; 
   
   assign  MOSI  = cmd_addr[31];
   // initial CS_N  = 1'b1;
   assign  CLK   = !CS_N && !clk; // CLK needs to be inverted (sample on posedge, shift of negedge) 
                                  // and needs to be disabled when not sending/receiving (&& !CS_N).

   // since least significant bytes are read first, we need to swizzle...
   assign rdata = {rcv_data[7:0],rcv_data[15:8],rcv_data[23:16],rcv_data[31:24]};
   
   always @(posedge clk) begin
      if (!reset) begin CS_N <= 1; end
         else if(rstrb) begin
	            CS_N <= 1'b0;
	            cmd_addr <= {8'h03, 2'b00,word_address[19:0], 2'b00};
	            snd_bitcount <= 6'd32;
               // rcv_bitcount <= 6'd32;
      end else begin
	 if (sending) begin
	    if(snd_bitcount == 1) begin
	       rcv_bitcount <= 6'd32;
	    end
	    snd_bitcount <= snd_bitcount - 6'd1;
	    cmd_addr <= {cmd_addr[30:0],1'b1};
    end else
	 if(receiving) begin
	    rcv_bitcount <= rcv_bitcount - 6'd1;
	    rcv_data <= {rcv_data[30:0],MISO};
	 end
	 if(!busy) begin
	    CS_N <= 1'b1;
	 end
      end
   end
endmodule
`endif
/*************************************************************************************/

/**********************************************************************************************************/
                     // UART
/**********************************************************************************************************/
// `include "uart.v"           // The UART (serial port over USB)

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
/**********************************************************************************************************/

module femtosoc(
`ifdef NRV_IO_LEDS
               output D1,D2,D3,D4,D5, 
`endif	      

`ifdef NRV_IO_PWM
               output D1,
`endif	      

`ifdef NRV_IO_UART
					 input  RXD,
					 output TXD,
`endif	      

`ifdef NRV_SPI_FLASH
					 output spi_mosi, input spi_miso, output spi_cs_n,
 `ifndef ULX3S	
					 output spi_clk, // ULX3S has spi clk shared with ESP32, using USRMCLK (below)	
 `endif
`endif

`ifdef ULX3S
					 output wifi_en,		
`endif		
   input  RESET,

`ifdef RV_DEBUG_ICESUGAR_NANO
					 output board_led,
`endif
					input clk
);

	
/********************* Technicalities **************************************/
   
// On the ULX3S, deactivate the ESP32 so that it does not interfere with 
// the other devices (especially the SDCard).
`ifdef ULX3S
   assign wifi_en = 1'b0;
`endif		

// On the ULX3S, the CLK pin of the SPI is multiplexed with the ESP32.
// It can be accessed using the USRMCLK primitive of the ECP5
// as follows.
`ifdef NRV_SPI_FLASH
 `ifdef ULX3S
   wire   spi_clk;
   wire   tristate = 1'b0;
   `ifndef BENCH   
      USRMCLK u1 (.USRMCLKI(spi_clk), .USRMCLKTS(tristate));
   `endif
  `endif
`endif

 

  // A little delay for sending the reset signal after startup.
  // Explanation here: (ice40 BRAM reads incorrect values during
  // first cycles).
  // http://svn.clifford.at/handicraft/2017/ice40bramdelay/README
  // On the ICE40-UP5K, 4096 cycles do not suffice (-> 65536 cycles)
   
`ifndef ASIC

reg [15:0] reset_cnt;
 
wire       reset = &reset_cnt;


/* verilator lint_off WIDTH */   
`ifdef NRV_NEGATIVE_RESET
   always @(posedge clk,negedge RESET) begin
      if(!RESET) begin
	 reset_cnt <= 0;
      end else begin
	 reset_cnt <= reset_cnt + !reset;
      end
   end
`else
   always @(posedge clk,posedge RESET) begin
      if(RESET) begin
	 reset_cnt <= 0;
      end else begin
	 reset_cnt <= reset_cnt + !reset;
      end
   end
`endif
`else
   reg reg1, reg2, reg3;
   always@(posedge clk, negedge RESET) begin
      if (!RESET)
         reg1 <= 1'b0;
      else reg1 <= 1'b1;
   end
   always@(posedge clk) begin
      reg2 <= reg1;
      reg3 <= reg2;
   end

wire  reset;
assign reset = reg3;
`endif
/* verilator lint_on WIDTH */   
   
/***************************************************************************************************
/*
 * Memory and memory interface
 * memory map:
 *   address[21:2] RAM word address (4 Mb max).
 *   address[23:22]   00: RAM
 *                    01: IO page (1-hot)  (starts at 0x400000)
 *                    10: SPI Flash page   (starts at 0x800000)
 */ 

   // The memory bus.
   wire [31:0] mem_address; // 24 bits are used internally. The two LSBs are ignored (using word addresses)
   wire  [3:0] mem_wmask;   // mem write mask and strobe /write Legal values are 000,0001,0010,0100,1000,0011,1100,1111
   wire [31:0] mem_rdata;   // processor <- (mem and peripherals) 
   wire [31:0] mem_wdata;   // processor -> (mem and peripherals)
   wire        mem_rstrb;   // mem read strobe. Goes high to initiate memory write.
   wire        mem_rbusy;   // processor <- (mem and peripherals). Stays high until a read transfer is finished.
   wire        mem_wbusy;   // processor <- (mem and peripherals). Stays high until a write transfer is finished.

   wire        mem_wstrb = |mem_wmask; // mem write strobe, goes high to initiate memory write (deduced from wmask)

   // IO bus.
`ifdef NRV_MAPPED_SPI_FLASH
   wire mem_address_is_ram       = (mem_address[23:22] == 2'b00);   
   wire mem_address_is_io        = (mem_address[23:22] == 2'b01);
   wire mem_address_is_spi_flash = (mem_address[23:22] == 2'b10);
   wire mapped_spi_flash_rbusy;
   wire [31:0] mapped_spi_flash_rdata;
   
   MappedSPIFlash mapped_spi_flash(
      .clk(clk),
      .reset(reset),
      .rstrb(mem_rstrb && mem_address_is_spi_flash),
      .word_address(mem_address[21:2]),
      .rdata(mapped_spi_flash_rdata),
      .rbusy(mapped_spi_flash_rbusy),
      .CLK(spi_clk),
      .CS_N(spi_cs_n),
`ifdef SPI_FLASH_FAST_READ_DUAL_IO				   
      .IO({spi_miso,spi_mosi})
`else	
      .MISO(spi_miso),
      .MOSI(spi_mosi)
`endif				   
   );
`else   
   wire mem_address_is_io  =  mem_address[22];
   wire mem_address_is_ram = !mem_address[22];
`endif
      
   reg  [31:0] io_rdata; 
   wire [31:0] io_wdata = mem_wdata;
   wire        io_rstrb = mem_rstrb && mem_address_is_io;
   wire        io_wstrb = mem_wstrb && mem_address_is_io;
   wire [19:0] io_word_address = mem_address[21:2]; // word offset in io page
   wire	       io_rbusy; 
   wire        io_wbusy;
   
   assign      mem_rbusy = io_rbusy
`ifdef NRV_MAPPED_SPI_FLASH
    | mapped_spi_flash_rbusy			   
`endif 			   
    ;
   
   assign      mem_wbusy = io_wbusy; 

`ifdef NRV_IO_FGA
   wire mem_address_is_vram = mem_address[21];
`else
   parameter mem_address_is_vram = 1'b0;
`endif

   wire [19:0] ram_word_address = mem_address[21:2];

// Using the 128 KBytes of SPRAM (single-ported RAM) embedded in the Ice40 UP5K   
`ifdef ICE40UP5K_SPRAM

   wire [31:0]  ram_rdata;
   wire 	spram_wr = mem_address_is_ram && !mem_address_is_vram;
   ice40up5k_spram RAM(
      .clk(clk),
      .wen({4{spram_wr}} & mem_wmask),
      .addr(ram_word_address[14:0]),
      .wdata(mem_wdata),
      .rdata(ram_rdata)		       
   );

`else // Synthethizing BRAM
   
   reg [31:0] RAM[0:(`NRV_RAM/32)-1];
   reg [31:0] ram_rdata;

   // Initialize the RAM with the generated firmware hex file.
   // The hex file is generated by the bundled elf-2-verilog converter (see TOOLS/FIRMWARE_WORDS_SRC)
`ifndef NRV_RUN_FROM_SPI_FLASH  
   initial begin
		$readmemh("hex.hex", RAM); 
   end
`endif

   // The power of YOSYS: it infers BRAM primitives automatically ! (and recognizes
   // masked writes, amazing ...)
   /* verilator lint_off WIDTH */
   always @(posedge clk) begin
      if(mem_address_is_ram && !mem_address_is_vram) begin
	 if(mem_wmask[0]) RAM[ram_word_address][ 7:0 ] <= mem_wdata[ 7:0 ];
	 if(mem_wmask[1]) RAM[ram_word_address][15:8 ] <= mem_wdata[15:8 ];
	 if(mem_wmask[2]) RAM[ram_word_address][23:16] <= mem_wdata[23:16];
	 if(mem_wmask[3]) RAM[ram_word_address][31:24] <= mem_wdata[31:24];	 
      end 
      ram_rdata <= RAM[ram_word_address];
   end
   /* verilator lint_on WIDTH */
`endif
      
`ifdef NRV_MAPPED_SPI_FLASH
   assign mem_rdata = mem_address_is_io  ? io_rdata  : 
		      mem_address_is_ram ? ram_rdata : 
		      mapped_spi_flash_rdata;   
`else   
   assign mem_rdata = mem_address_is_io ? io_rdata : ram_rdata;
`endif   
   
/***************************************************************************************************
/*
 * Memory-mapped IO
 * Mapped IO uses "one-hot" addressing, to make decoder
 * simpler (saves a lot of LUTs), as in J1/swapforth,
 * thanks to Matthias Koch(Mecrisp author) for the idea !
 * The included files contains the symbolic constants that
 * determine which device uses which bit.
 */ 

// `include "HardwareConfig_bits.v"   

/*
 * Devices are components plugged to the IO memory bus.
 * A few words follow in case you want to write your own devices:
 *
 * Each device has one or several register(s). Each register 
 * can be optionally read or/and written.
 * - Each register is selected by a .sel_xxx signal (where xxx
 *   is the name of the register). With the 1-hot encoding that 
 *   I'm using, .sel_xxx is systematically one of the bits of the 
 *   IO word address (it is also possible to write a real
 *   address decoder, at the expense of eating-up a larger 
 *   number of LUTs).
 * - If the device requires wait cycles for writing and/or reading, 
 *   it can have a .wbusy and/or .rbusy signal(s). All the .wbusy
 *   and .rbusy signals of all the devices are ORed at the end of
 *   this file to form the .io_rbusy and .io_wbusy signals.
 * - If the device has read access, then it has a 32-bits .xxx_rdata
 *   signal, that returns 32'b0 if the device is not selected, or the
 *   read data otherwise. All the .xxx_rdata signals of all the devices
 *   are ORed at the end of this file to form the 32-bits io_rdata signal.
 * - Finally, of course, each device is plugged to some pins of the FPGA,
 *   the corresponding signals are in capital letters. 
 */   


/*********************** Hardware configuration ************/
/*
 * Three memory-mapped constant registers that make it easy for
 * client code to query installed RAM and configured devices
 * (this one does not use any pin, of course).
 * Uses some LUTs, a bit stupid, but more comfortable, so that
 * I do not need to change the software on the SDCard each time 
 * I test a different hardware configuration.
 */
`ifdef NRV_IO_HARDWARE_CONFIG   
wire [31:0] hwconfig_rdata;
HardwareConfig hwconfig(
   .clk(clk),			
   .sel_memory(io_word_address[17]),
   .sel_devices(io_word_address[18]),
   .sel_cpuinfo(io_word_address[19]),			
   .rdata(hwconfig_rdata)			 
);
`endif
   
/*********************** Four LEDs ************************/
`ifdef NRV_IO_LEDS
   wire [31:0] leds_rdata;
   LEDDriver leds(
`ifdef NRV_IO_IRDA
      .irda_TXD(irda_TXD),
      .irda_RXD(irda_RXD),
      .irda_SD(irda_SD),		
`endif		  
      .clk(clk),
      .rstrb(io_rstrb),		  
      .wstrb(io_wstrb),			
      .sel(io_word_address[0]),
      .wdata(io_wdata),		  
      .rdata(leds_rdata),
      .LED({D4,D3,D2,D1})
   );
`endif

/********************** SSD1351/SSD1331 oled display ******/
 

/********************** UART ****************************************/
`ifdef NRV_IO_UART

 // Internal wires to connect IO buffers to UART
 wire RXD_internal;
 wire TXD_internal;
   
 `ifdef ULX3S
   `ifndef BENCH_OR_LINT
     // On the ULX3S, we need to latch RXD, using the latch
     // embedded in the input buffer. If we do not do that,
     // then we unpredictably get garbage on the UART.
     // The two primitives BB (bidirectional three-state buffer)
     // and IFS1P3BX (latch in IO pin) are interpreted by the
     // synthesis tool as an IO cell.
     wire RXD_btw;
     BB RXD_bb(
       .I(1'b0), 
       .O(RXD_btw), 
       .B(RXD), 
       .T(1'b1)
     );
     IFS1P3BX RXD_pin(
       .SCLK(clk),		    
       .D(RXD_btw),
       .Q(RXD_internal),
       .PD(1'b0)		    
     );
     assign TXD = TXD_internal; // For now, do not latch output (but we may need to)
     `define UART_IO_BUFFER
   `endif
 `endif
 
 // For other boards, we directly connect RXD and TXD to the UART (but we may need
 // to latch).
 `ifndef UART_IO_BUFFER
   assign RXD_internal = RXD;
   assign TXD = TXD_internal;
 `endif

   wire        uart_brk;
   wire [31:0] uart_rdata;
   UART uart(
      .clk(clk),
      .rstrb(io_rstrb),	     	     
      .wstrb(io_wstrb),
      .sel_dat(io_word_address[1]),
      .sel_cntl(io_word_address[2]),	     
      .wdata(io_wdata),
      .rdata(uart_rdata),
      .RXD(RXD_internal),
      .TXD(TXD_internal),
      .brk(uart_brk)
   );
`else
   wire uart_brk = 1'b0;
`endif 
   
/************** io_rdata, io_rbusy and io_wbusy signals *************/

/*
 * io_rdata is latched. Not mandatory, but probably allow higher freq, to be tested.
 */
always @(posedge clk) begin
   io_rdata <= 0
`ifdef NRV_IO_HARDWARE_CONFIG	       
            | hwconfig_rdata
`endif	       
`ifdef NRV_IO_LEDS      
	    | leds_rdata
`endif
`ifdef NRV_IO_UART
	    | uart_rdata
`endif	    
`ifdef NRV_IO_SDCARD
	    | sdcard_rdata
`endif
`ifdef NRV_IO_BUTTONS
	    | buttons_rdata
`endif
`ifdef NRV_IO_FGA
	    | FGA_rdata
`endif
	    ;
end

   // For now, we got no device that has
   // blocking reads (SPI flash blocks on
   // write address and waits for read data).
   assign io_rbusy = 0 ; 

   assign io_wbusy = 0
`ifdef NRV_IO_SSD1351_1331
	| SSD1351_wbusy
`endif
`ifdef NRV_IO_MAX7219
	| max7219_wbusy
`endif		   
`ifdef NRV_IO_SPI_FLASH
        | spi_flash_wbusy
`endif		   
; 

/********************************************/
/* PWM */
`ifdef NRV_IO_PWM
pwm #(
   .WIDTH(12)
) pwm (
   .reset(reset),
   .clk(clk),
   .wstrb(io_wstrb),
   .sel(io_word_address[12]),
   .wdata(io_wdata),
   .led(D1)
);
`endif

/****************************************************************/
/* And last but not least, the processor                        */
   reg error=1'b0;

   
  FemtoRV32 #(
     .ADDR_WIDTH(`NRV_ADDR_WIDTH),
     .RESET_ADDR(`NRV_RESET_ADDR)	      
  ) processor(
    .clk(clk),			
    .mem_addr(mem_address),
    .mem_wdata(mem_wdata),
    .mem_wmask(mem_wmask),
    .mem_rdata(mem_rdata),
    .mem_rstrb(mem_rstrb),
    .mem_rbusy(mem_rbusy),
    .mem_wbusy(mem_wbusy),
`ifdef NRV_INTERRUPTS
    .interrupt_request(1'b0),	      
`endif     
    //.reset(reset && !uart_brk) // v1
    .reset(reset) // v2
);

`ifdef NRV_IO_LEDS  
   assign D5 = error;
 `ifdef FOMU
    SB_RGBA_DRV #(
        .CURRENT_MODE("0b1"),       // half current
        .RGB0_CURRENT("0b000011"),  // 4 mA
        .RGB1_CURRENT("0b000011"),  // 4 mA
        .RGB2_CURRENT("0b000011")   // 4 mA
    ) RGBA_DRIVER (
        .CURREN(1'b1),
        .RGBLEDEN(1'b1),
        .RGB0PWM(D1), 
        .RGB1PWM(D2), 
        .RGB2PWM(D3), 
        .RGB0(rgb0),
        .RGB1(rgb1),
        .RGB2(rgb2)
    );
 `endif
`endif

	/* ****************************** RV DEBUG iCESugar-nano ****************************** */
	/* for debugging purposes */
`ifdef RV_DEBUG_ICESUGAR_NANO
	led_blink 
	  my_debug_led(
                  .clk(pclk),     // clock signal
                  .reset(reset),
                  .led(board_led) // yellow led in the icesugar-nano board v1.2
                  );
`endif
	/* ************************************************************************************* */
	
endmodule
