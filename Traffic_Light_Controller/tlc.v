module tlc(pclk,prst,paddr,pvalid,prdata,pwdata,pready,state,prd_wr);

input pclk,prst,prd_wr;
input [7:0] paddr;
input [31:0] pwdata;
input pvalid;

output reg [31:0] prdata;
output reg pready;
output reg state;

//registers
reg next_state;
reg [31:0] red_time_reg;     //2 values for time is stored. lower 16 for high traffic mode and higher 16 for low traffic mode.
reg [31:0] yellow_time_reg;  
reg [31:0] green_time_reg;
reg [31:0] mode_reg;         //5 modes - Low traffic, High traffic, Blinking, Off, Manual. ie 3 bits are used.
reg [31:0] status_reg;


/*
8'h00 -> red_time_reg
8'h04 -> yellow_time_reg
8'h08 -> green_time_reg
8'h0C -> mode_reg
8'h10 -> status_reg
*/

//defining parameters for state
parameter OFF = 3'b000;
parameter BLANK = 3'b001;
parameter RED = 3'b010;
parameter YELLOW = 3'b011;
parameter GREEN = 3'b100;

//defining parameters for mode_reg
parameter SWITCHOFF = 3'b000;
parameter BLINK = 3'b001;
parameter MANUAL = 3'b010;
parameter HIGH = 3'b011;
parameter LOW = 3'b100;

always @ (next_state) 
	state = next_state;

always @ (posedge pclk) begin
	if (prst == 0) begin
		yellow_time_reg = 0;
		red_time_reg = 0;
		green_time_reg = 0;
		mode_reg = 0;
		status_reg = 0;
		prdata = 0;
		pready = 0;
		next_state = RED;
	end
	else begin
		if (pvalid == 1) begin
			pready = 1;
			if (prd_wr == 1) begin
				if(paddr == 8'h00) red_time_reg = pwdata;
				if(paddr == 8'h04) yellow_time_reg = pwdata;
				if(paddr == 8'h08) green_time_reg = pwdata;
				if(paddr == 8'h0C) mode_reg = pwdata;
				if(paddr == 8'h10) status_reg = pwdata;
			end
			else begin
				if(paddr == 8'h00) prdata = red_time_reg;
				if(paddr == 8'h04) prdata = yellow_time_reg;
				if(paddr == 8'h08) prdata = green_time_reg;
				if(paddr == 8'h0C) prdata = mode_reg;
				if(paddr == 8'h10) prdata = status_reg;
			end
		end
		else begin
			pready = 0;
		end
	end
end

always @ (posedge pclk) begin
	status_reg = {29'b0,state};
	case(state)
		RED : begin
			if (mode_reg == HIGH) begin
				#(red_time_reg[31:16]);
				next_state = YELLOW;
			end
			if (mode_reg == LOW) begin
				#(red_time_reg[15:0]);
				next_state = YELLOW;
			end
			if (mode_reg == BLINK) next_state = BLANK;
			if (mode_reg == MANUAL) next_state = RED;
			if (mode_reg == SWITCHOFF) next_state = OFF;
		end
		YELLOW : begin
			if (mode_reg == HIGH) begin
				#(red_time_reg[31:16]);
				next_state = GREEN;
			end
			if (mode_reg == LOW) begin
				#(red_time_reg[15:0]);
				next_state = GREEN;
			end
			if (mode_reg == BLINK) next_state = BLANK;
			if (mode_reg == MANUAL) next_state = RED;
			if (mode_reg == SWITCHOFF) next_state = OFF;
		end	
		GREEN : begin
			if (mode_reg == HIGH) begin
				#(red_time_reg[31:16]);
				next_state = RED;
			end
			if (mode_reg == LOW) begin
				#(red_time_reg[15:0]);
				next_state = RED;
			end
			if (mode_reg == BLINK) next_state = BLANK;
			if (mode_reg == MANUAL) next_state = RED;
			if (mode_reg == SWITCHOFF) next_state = OFF;
		end
		BLINK : begin	
			if (mode_reg == HIGH) begin
				next_state = RED;
			end
			if (mode_reg == LOW) begin
				next_state = RED;
			end
			if (mode_reg == BLINK) next_state = YELLOW;
			if (mode_reg == MANUAL) next_state = RED;
			if (mode_reg == SWITCHOFF) next_state = OFF;
		end	
		SWITCHOFF : begin
			if (mode_reg == HIGH) begin
				next_state = RED;
			end
			if (mode_reg == LOW) begin
				next_state = RED;
			end
			if (mode_reg == BLINK) next_state = BLANK;
			if (mode_reg == MANUAL) next_state = RED;
			if (mode_reg == SWITCHOFF) next_state = OFF;
		end
	endcase
end

endmodule
