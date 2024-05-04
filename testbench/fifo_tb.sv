module asynch_fifo_tb;
parameter DEPTH= 333; parameter A_SIZE = 8; 
bit w_clk,r_clk;
bit reset,wr_en,rd_en;
logic [A_SIZE-1:0]w_data;
logic [A_SIZE-1:0]r_data;
logic w_full,r_empty,almost_w_full,almost_r_empty;
logic[8:0]rdptr,wrptr;



 asynchronous_fifo dut (.w_clk(w_clk),.wrst_n(reset),.r_clk(r_clk),.rrst_n(reset),
                            .w_enable(wr_en),.r_enable(rd_en),.w_data(w_data),.r_data(r_data),.w_full(w_full),.r_empty(r_empty),.write_error(almost_w_full),
                            .read_error(almost_r_empty));
initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);
end
 

initial begin
$monitor("time = %d, rrst_n = %b, read_ptr = %d,  wdata = %b, wrst_n = %b, write_ptr = %d, rdata = %b", $time, reset, dut.g_rptr,w_data, reset, dut.g_wptr, dut.fifom.r_data);
end

//clock generation
initial begin
    w_clk = 1'b0;
    r_clk = 1'b0;

    fork
      forever #1ns w_clk = ~w_clk;
      forever #2222ps r_clk = ~r_clk;
    join
  end


task initialize;
begin
w_data='0;
wr_en='0;
rd_en='0;
end
endtask

task rst;
@(negedge w_clk)
@(negedge r_clk)
reset=1'b0;
@(negedge w_clk)
@(negedge r_clk)
reset=1'b1;
endtask

task write;
begin
for(int i=0;i<256;i++) begin
@(posedge w_clk);
wr_en=1'b1;
w_data=i;
repeat(1) @(posedge w_clk);
end

@(posedge w_clk);
wr_en=1'b0;
w_data=0;
end
endtask

task read;
begin
for(int i=0; i<256; i++)begin
@(posedge r_clk);
rd_en=1'b1;
repeat(3) @(posedge r_clk);
end

@(posedge r_clk);
rd_en=1'b0;
end
endtask

initial
#8000 $finish();

  initial begin
    initialize;
    rst;
    fork
      write;
      read;
    join
    end

endmodule