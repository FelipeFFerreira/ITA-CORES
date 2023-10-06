/*******************************************************************/
// FemtoRV32, a collection of minimalistic RISC-V RV32 cores.
// This version: The "Quark", the most elementary version of FemtoRV32.
//             A single VERILOG file, compact & understandable code.
//             (200 lines of code, 400 lines counting comments)
//
// Instruction set: RV32I + RDCYCLES
//
// Parameters:
//  Reset address can be defined using RESET_ADDR (default is 0).
//
//  The ADDR_WIDTH parameter lets you define the width of the internal
//  address bus (and address computation logic).
//
// Macros:
//    optionally one may define NRV_IS_IO_ADDR(addr), that is supposed to:
//              evaluate to 1 if addr is in mapped IO space,
//              evaluate to 0 otherwise
//    (additional wait states are used when in IO space).
//    If left undefined, wait states are always used.
//
//    NRV_COUNTER_WIDTH may be defined to reduce the number of bits used
//    by the ticks counter. If not defined, a 32-bits counter is generated.
//    (reducing its width may be useful for space-constrained designs).
//
//    NRV_TWOLEVEL_SHIFTER may be defined to make shift operations faster
//    (uses a two-level shifter inspired by picorv32).
//
// Bruno Levy, Matthias Koch, 2020-2021
/*******************************************************************/

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