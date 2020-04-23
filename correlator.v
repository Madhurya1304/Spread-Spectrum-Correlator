module correlator(input clk, reset, sync, push_samp, MJ, flag,input signed [11:0] samp, output signed [31:0] corr);

reg signed [31:0] corr1,corr1_d;

assign corr = corr1;


always@(*) begin
	if (sync) corr1_d = 0;
	else if (push_samp) begin
			if (MJ) begin
				if(flag != 1) corr1_d = corr1 + samp;
				else corr1_d = 0 + samp;

			end else begin
				if(flag != 1) corr1_d = corr1 - samp;
                                else corr1_d = 0 - samp;
			end
	end else begin
			if(flag != 1) corr1_d = corr1;
			else corr1_d = 0;
		end
end




always @(posedge(clk) or posedge(reset)) begin
	if (reset) begin
		corr1 <= 0;
	end else begin
		corr1 <= #1 corr1_d;
	end
end

endmodule

