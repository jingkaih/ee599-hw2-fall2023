module double_buffer
#( 
  parameter DATA_WIDTH = 64,
  parameter BANK_ADDR_WIDTH = 7,
  parameter [BANK_ADDR_WIDTH : 0] BANK_DEPTH = 128
)(
  input clk,
  input rst_n,
  input switch_banks,
  input ren,
  input [BANK_ADDR_WIDTH - 1 : 0] radr,
  output [DATA_WIDTH - 1 : 0] rdata,
  input wen,
  input [BANK_ADDR_WIDTH - 1 : 0] wadr,
  input [DATA_WIDTH - 1 : 0] wdata
);
  // Implement a double buffer with the dual-port SRAM (ram_sync_1r1w)
  // provided. This SRAM allows one read and one write every cycle. To read
  // from it you need to supply the address on radr and turn ren (read enable)
  // high. The read data will appear on rdata port after 1 cycle (1 cycle
  // latency). To write into the SRAM, provide write address and data on wadr
  // and wdata respectively and turn write enable (wen) high. 
  
  // You can implement both double buffer banks with one dual-port SRAM.
  // Think of one bank consisting of the first half of the addresses of the
  // SRAM, and the second bank consisting of the second half of the addresses.
  // If switch_banks is high, you need to switch the bank you are reading with
  // the bank you are writing on the clock edge.

  // Your code starts here
  
  // define the double buffer's full address space to be the double of each bank's addr space
  // note that FULL_ADDR_WIDTH should be the address space of the sram_sync_1r1w instance
  parameter FULL_ADDR_WIDTH = BANK_ADDR_WIDTH + 1;
  // define state variable current_bank
  reg current_bank;
  // define wadr and radr which are mutually exclusive,
  // i.e., I have this: (4 addresses each bank so BANK_ADDR_WIDTH = 2 but I will have to instantiate a 8 addresses SRAM )
  //                        bank0
  //                        bank0
  // bank0 | bank1          bank0
  // bank0 | bank1          bank0
  // bank0 | bank1  ==>     bank1
  // bank0 | bank1          bank1
  //                        bank1
  //                        bank1
  // Once reset, the SRAM will be configured as bank0-write, bank1-read
  // On the first switch_banks press after reset, we get bank0-read, bank1-write
  wire [FULL_ADDR_WIDTH - 1 : 0] wadr_actual;
  wire [FULL_ADDR_WIDTH - 1 : 0] radr_actual;

  always @( * ) begin
    if( current_bank == 1'b0 ) begin
      wadr_actual = wadr;
      radr_actual = radr + BANK_DEPTH;
    end 
    else begin
      wadr_actual = wadr + BANK_DEPTH;
      radr_actual = radr;
    end
  end
  // SRAM instance
  ram_sync_1r1w
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(FULL_ADDR_WIDTH),
    .DEPTH(2 * BANK_DEPTH)// SRAM should have depth = 2*bank depth
  )
  ram_instance (
    .clk(clk),
    .wen(wen),
    .wadr(wadr_actual),
    .wdata(wdata),
    .ren(ren),
    .radr(radr_actual),
    .rdata(rdata)
  );

  always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
      current_bank <= 0;
    else if ( switch_banks )
      current_bank <= ~current_bank;
  end
 
  // Your code ends here
endmodule
