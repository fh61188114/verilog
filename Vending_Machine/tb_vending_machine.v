`include "vending_machine.v"

module tb;

reg pclk, prst, coin_valid;
reg [2:0] coin;
reg pvalid, wr_rd;
reg [15:0] paddr;
reg [15:0] pwdata;
reg [3:0] num_of_tea_reqd;
reg [3:0] num_of_coffee_reqd;
reg [3:0] num_of_milk_reqd;

wire pready;
wire [7:0] prdata;
wire machine_ready;
wire [3:0] num_of_tea_served;
wire [3:0] num_of_coffee_served;
wire [3:0] num_of_milk_served;

reg [15:0] rdata;

vending_machine dut (.pclk(pclk),.prst(prst),.pvalid(pvalid),.pready(pready),.paddr(paddr),.pwdata(pwdata),.prdata(prdata),.wr_rd(wr_rd),.coin(coin),.coin_valid(coin_valid),.num_of_tea_reqd(num_of_tea_reqd),.num_of_coffee_reqd(num_of_coffee_reqd),.num_of_milk_reqd(num_of_milk_reqd),.num_of_tea_served(num_of_tea_served),.num_of_coffee_served(num_of_coffee_served),.num_of_milk_served(num_of_milk_served),.machine_ready(machine_ready));

initial begin
	pclk = 0;
	forever #5 pclk = ~pclk;
end

initial begin
	prst = 1;
	repeat(2) @(posedge pclk) 
	prst = 0;
end

task write_reg (input reg [15:0] addr, input reg [15:0] data);
	begin
		@ (posedge pclk);
		paddr = addr;
		pwdata = data;
		pvalid = 1;
		wr_rd = 1;
		wait(pready == 1)
		wr_rd = 0;
		pvalid = 0;
	end
endtask


task read_reg (input reg [15:0] addr, output reg [15:0] data);
	begin
		@ (posedge pclk);
		paddr = addr;
		pvalid = 1;
		wr_rd = 0;
		wait(pready == 1)
		@ (posedge pclk) data = pwdata;
		wr_rd = 0;
		pvalid = 0;
	end
endtask

initial begin
	#5 write_reg(16'h00, 16'd150);
	#30 write_reg(16'h04, 16'd175);
	#35 write_reg(16'h08, 16'd125);
	num_of_tea_reqd = 3'd3; 
	num_of_coffee_reqd = 3'd1; 
	num_of_milk_reqd = 3'd1; 
	#1 coin = 3'b001;
	#2 coin = 3'b010;
	#3 coin = 3'b001;
	#4 coin = 3'b010;
	#5 coin = 3'b001;
	#6 coin = 3'b011;
	#7 coin = 3'b001;
	#8 coin = 3'b100;
	#110 $finish;
end
endmodule
