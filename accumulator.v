module accumulator ( input clk,input reset,input sync,input push_s, input [31:0] phase,input[31:0] freq, output sync1, output ovf);
reg [31:0] acc_d, acc;
reg ovf1_d, ovf1;
reg syn1_d, syn1;

assign sync1 = syn1;
assign ovf = ovf1;

always @(*) begin
	syn1_d = sync;
	if (sync) begin
		acc_d = phase;
		ovf1_d = 0;
	end else if(push_s) begin
			acc_d = acc + freq;
			if (acc_d < 32'd100000000) begin
				acc_d = acc_d;
				ovf1_d = 0;
			end else begin
			       	ovf1_d = 1;
				acc_d = acc_d - 32'd100000000;
			end

	end else begin
 		acc_d = acc;
		ovf1_d = 0;
	end
end

always @(posedge (clk) or posedge(reset)) begin
	if (reset) begin
		syn1 <= 0;
		acc <= 0;
		ovf1 <= 0;
	end else begin 
		syn1 <= #1 syn1_d;
		acc <= #1 acc_d;
		ovf1 <= #1 ovf1_d;
	end
end	

endmodule

			




