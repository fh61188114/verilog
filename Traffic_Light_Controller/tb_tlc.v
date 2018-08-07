`include "tlc.v"
module tb;
reg pclk,prst,prd_wr;
reg [31:0] paddr;
reg [31:0] pwdata;
reg pvalid;

wire [31:0] prdata;
wire pready;
wire [2:0] state;

reg [31:0] rdata;

tlc dut (.pclk(pclk),.prst(prst),.paddr(paddr),.pvalid(pvalid),.prdata(prdata),.pwdata(pwdata),.pready(pready),.state(state),.prd_wr(prd_wr));

initial begin
	pclk = 0;
	forever #5 pclk =~pclk;
end

initial begin
	prst = 0;
	repeat(2) @ (posedge pclk);
	prst =1;
end
// task to write to registers
task write_reg (input reg [7:0] addr, input reg [31:0] data);
	begin
		@(posedge pclk);
		paddr = addr;
		pwdata = data;
		pvalid = 1;
		prd_wr = 1;
		wait(pready ==1);
		prd_wr = 0;
		pvalid = 0;
	end
endtask

task read_reg (input reg [7:0] addr, input reg [31:0] data);
	begin
		@(posedge pclk);
		paddr = addr;
		pvalid = 1;
		prd_wr = 0;
		wait(pready ==1);
		@(posedge pclk)
		data = prdata;
		prd_wr = 1;
		pvalid = 0;
	end
endtask
// stimulus
initial begin
// write to all the registers using created tasks
	#10 write_reg(8'h00,{16'd100,16'd30}); //red time reg: high traffic mode time = 100 units. low traffic mode time = 20 units.
	#15 write_reg(8'h04,{16'd30,16'd5});   //yellow time reg.
	#20 write_reg(8'h08,{16'd80,16'd25}); //green time reg.
	#25 write_reg(8'h0C,{29'd0,3'b100});   //mode reg : 100 corresponds to low traffic mode.
//read from registers and display it
	#25 read_reg(8'h00,rdata);
//$display("rdata = %h", rdata);
	#30 read_reg(8'h04,rdata);
//$display("rdata = %h", rdata);
	#35 read_reg(8'h08,rdata);
//$display("rdata = %h", rdata);
	#40 read_reg(8'h0C,rdata);
//$display("rdata = %h", rdata);
	#45 read_reg(8'h10,rdata);
//$display("rdata = %h", rdata);
	#500 write_reg(8'h0C,{29'd0,3'b011});   //mode reg : 011 corresponds to high traffic mode.
	#1000 write_reg(8'h0C,{29'd0,3'b001});   //mode reg : 001 corresponds to blink traffic mode.
	#1500 $finish;
end
endmodule
