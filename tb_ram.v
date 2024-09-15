`include "defines.v"

module top;
  // Declare signals
  reg clk, rstn, en, wr_rd;
  reg [`data_width-1:0] data_in;
  reg [`addr_width-1:0] addr;
  wire [`data_width-1:0] data_out;
  wire out_en;
  reg [`data_width-1:0] temp [`depth-1:0];  // Internal memory for testbench

  // Local variables
  reg [`addr_width-1:0] addr_l;
  reg [`data_width-1:0] data_out_l;

  // Instantiate the RAM module (DUT)
  ram dut (
    .clk(clk),
    .rstn(rstn),
    .en(en),
    .addr(addr),
    .wr_rd(wr_rd),
    .data_in(data_in),
    .data_out(data_out),
    .out_en(out_en)
  );

  // Clock generation logic
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset generation logic
  initial begin
    en = 1;
    rstn = 0;  // Active low reset
    #10;
    rstn = 1;  // Release reset
  end

  // Main sequence: write, read, compare
  initial begin
    write_mem();
    #50;
    read_mem();
    comp();
  end

  // Task to write to the RAM
  task write_mem();
    begin
      wr_rd = 1;  // Write operation
      addr = $random;  // Random address
      data_in = $random;  // Random data
      addr_l = addr;  // Store the address
      temp[addr_l] = data_in;  // Store in temp array for comparison
      $display("Write packet: en=%h wr_rd=%h addr=%h data_in=%h", en, wr_rd, addr, data_in);
    end
  endtask

  // Task to read from the RAM
  task read_mem();
    begin
      wr_rd = 0;  // Read operation
      addr = addr_l;  // Read from the previously written address
      wait (out_en)  // Wait until data is available
      begin
        data_out_l = data_out;  // Capture the output data
      end
      $display("Read packet: en=%h wr_rd=%h addr=%h data_out=%h", en, wr_rd, addr, data_out);
    end
  endtask

  // Task to compare the written and read data
  task comp();
    begin
      if (temp[addr_l] == data_out_l) begin
        $display("RAM test PASSED");
        $display("temp[%h] = %h, data_out_l = %h", addr_l, temp[addr_l], data_out_l);
      end else begin
        $display("RAM test FAILED");
        $display("temp[%h] = %h, data_out_l = %h", addr_l, temp[addr_l], data_out_l);
      end
    end
  endtask

  // Logic to end the simulation
  initial begin
    #1000;
    $finish;
  end

endmodule

