module vending_machine(pclk,prst,pvalid,pready,paddr,pwdata,prdata,wr_rd,coin,coin_valid,num_of_tea_reqd,num_of_milk_reqd,num_of_coffee_reqd,num_of_tea_served,num_of_coffee_served,num_of_milk_served,machine_ready);

input pclk, prst, coin_valid;
input [2:0] coin;
input pvalid, wr_rd;
input [15:0] paddr;
input [15:0] pwdata;
output reg pready;
output reg [7:0] prdata;
output reg machine_ready;
output reg [3:0] num_of_tea_served;
output reg [3:0] num_of_coffee_served;
output reg [3:0] num_of_milk_served;

integer cost_of_products;
input [3:0] num_of_tea_reqd;
input [3:0] num_of_coffee_reqd;
input [3:0] num_of_milk_reqd;
integer total_amount_collected;
integer balance_amount;
integer remaining_money_to_insert;
reg [15:0] tea_cost;
reg [15:0] milk_cost;
reg [15:0] coffee_cost;

parameter PS25 = 3'b000;
parameter PS50 = 3'b001;
parameter RS1 = 3'b010;
parameter RS2 = 3'b011;
parameter RS5 = 3'b100;
parameter RS10 = 3'b101;
parameter INVALID = 3'b110;

always @ (posedge pclk) begin
	if (prst == 1) begin
		pready = 0;
		prdata = 0;
		machine_ready = 0;
		total_amount_collected = 0;
		num_of_tea_served = 0;
		num_of_coffee_served = 0;
		num_of_milk_served = 0;
		balance_amount = 0;
		remaining_money_to_insert = 0;
		tea_cost = 0;
		milk_cost = 0;
		coffee_cost = 0;
	end
	else begin
		if (pvalid == 1)
		begin
			pready = 1;
			if (wr_rd == 1)
			begin
				if (paddr == 16'h00) tea_cost = pwdata;
				if (paddr == 16'h04) coffee_cost = pwdata;
				if (paddr == 16'h08) milk_cost = pwdata;
				/*if (paddr == 8'h0C) num_of_tea_reqd = pwdata;
				if (paddr == 8'h10) num_of_coffee_reqd = pwdata;
				if (paddr == 8'h14) num_of_milk_reqd = pwdata;*/
		        end
			else begin
				if (paddr == 16'h00) prdata = tea_cost;
				if (paddr == 16'h04) prdata = coffee_cost;
				if (paddr == 16'h08) prdata = milk_cost;
			end
		end
		else begin
			pready = 0;
		end
	end
end

always @ (coin) begin
		machine_ready = 1;
		cost_of_products = (num_of_tea_reqd*tea_cost)+(num_of_coffee_reqd*coffee_cost)+(num_of_milk_reqd*milk_cost);
		$display("Bill Amount =%d", cost_of_products);
		case(coin)
			PS25 : begin
				total_amount_collected = total_amount_collected + 16'd25;
			end
			PS50 : begin
				total_amount_collected = total_amount_collected + 16'd50;
			end
			RS1 : begin
				total_amount_collected = total_amount_collected + 16'd100;
			end
			RS2 : begin
				total_amount_collected = total_amount_collected + 16'd200;
			end
			RS5 : begin
				total_amount_collected = total_amount_collected + 16'd500;
			end
			RS10 : begin
				total_amount_collected = total_amount_collected + 16'd1000;
			end
			INVALID : begin
				total_amount_collected = total_amount_collected + 16'd0;
			end
		endcase
			
		if (total_amount_collected >= cost_of_products) 
		begin
			num_of_tea_served = num_of_tea_reqd;
			num_of_coffee_served = num_of_coffee_reqd;
			num_of_milk_served = num_of_milk_reqd;
			balance_amount = total_amount_collected - cost_of_products;
			$display("Please Collect The Products, Balance Amount =%d", balance_amount);
		end	
		else begin
			num_of_tea_served = 0;
			num_of_coffee_served = 0;
			num_of_milk_served = 0;
			remaining_money_to_insert = cost_of_products - total_amount_collected;
			$display("Amount Insufficient, Money To Be Inserted =%d", remaining_money_to_insert);
		end
end
endmodule
