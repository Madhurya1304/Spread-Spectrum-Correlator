//`include "accumulator.v"
//`include "correlator.v"

//`timescale 1ns/10ps

module ss(clk,reset,din,dout,addr,strobe,samp,push_samp,sync,push_corr,corr);

input clk, reset; input [31:0]din; input [3:0]addr; input strobe;
input signed	[11:0]samp; input push_samp,sync;
output	push_corr; output [31:0] dout; output signed [31:0]corr;

reg [31:0]freq_d,freq,phase_d,phase; reg [31:0] s1_d,s2_d,s1,s2; reg ovf,ovf1,ovf1_d,feedback,VR,MJ_d,MJ,flag,flag_d,pusho,pusho_d = 0,sync1,sync2,sync3,sync1_d,sync2_d,sync3_d,push_s,push_s2,push_s3,push_s_d,push_s2_d,push_s3_d; 
reg [1:10] rnd,rnd_d,hp,hp_d; reg A,B,C,D;
reg ovf2_d, ovf2,push_s4,push_s4_d,flag1,flag1_d,pusho_1,pusho_1d;
reg dout1, dout1_d;
reg [10:0] counter_d,counter;
reg signed [11:0] samp1,samp1_d,samp2,samp2_d,samp3,samp3_d,samp4,samp4_d;
reg signed [31:0] corr1;
assign corr = corr1;
//assign push_corr = 0;
assign  push_corr =  pusho_1;
assign dout = dout1;
always @(*) begin
	if (strobe) begin
	freq_d = freq;
	phase_d = phase;
	s1_d = s1;
	s2_d = s2;
 	case(addr)

	 0: freq_d = din;

 	 4: phase_d = din;

	 8:begin
		if( din > 10) s1_d = 1; 
		else s1_d  = din;
	    end

    	12: begin 
		if( din > 10) s2_d = 1;
		else s2_d  =  din;
	end 


	endcase
	end else begin
        freq_d = freq;
        phase_d = phase;
        s1_d = s1;
        s2_d = s2;
        end
 

end


accumulator g1 (clk,reset,sync1,push_s,phase,freq,sync2,ovf);

always @ (*) begin 
	dout1_d = 32'd100000000;
	if (sync2) begin
             rnd_d = 10'b1111111111;
             hp_d = 10'b1111111111;
         end	else if (ovf1 == 1) begin 
	  		feedback = rnd[10] ^ rnd[3];
           	//	A = hp[1] ^ hp[2];
          	//	B = hp[3] ^ hp[5];
           	//	C = hp[8] ^ hp[9];
	   		VR = hp[2] ^ hp[3] ^ hp[6] ^ hp[8] ^ hp[9] ^ hp[10];  // (A ^ B) ^ C;

	    	  rnd_d[1] =  feedback;

                  rnd_d[10] =  rnd[9];

                  rnd_d[9] =  rnd[8];

                  rnd_d[8] =  rnd[7];

                  rnd_d[7] =  rnd[6];

                  rnd_d[6] =  rnd[5];

                  rnd_d[5] =  rnd[4];

                  rnd_d[4] =  rnd[3];

                  rnd_d[3] =  rnd[2];

                  rnd_d[2] =  rnd[1];


                  hp_d[1] =  VR;

                  hp_d[10] =  hp[9];

                  hp_d[9] =  hp[8];

                  hp_d[8] =  hp[7];

                  hp_d[7] =  hp[6];

                  hp_d[6] =  hp[5];

                  hp_d[5] =  hp[4];

                  hp_d[4] =  hp[3];

                  hp_d[3] =  hp[2];

                  hp_d[2] =  hp[1];
	  end else begin	 
			rnd_d = rnd;
			hp_d = hp;
		end
	

end
always @ (*) begin
	ovf1_d = ovf;
	ovf2_d = ovf1;

	if (sync2) MJ_d = 1;
	else if(ovf2) MJ_d = (hp[s1] ^ hp[s2])^ rnd[10];
	else MJ_d = MJ;
end

always @(posedge(clk) or posedge(reset)) begin
	if (reset) begin
		freq <= 0;
		phase <= 0;
		s1 <= 0;
		s2 <= 0;
		hp <= 0;
		rnd <= 0;
		MJ <= 0;
		ovf1 <= 0;
		ovf2 <= 0;
	end else begin
			freq <= #1 freq_d;
		phase <= #1 phase_d;
		s1 <= s1_d;
		s2 <= s2_d;

		hp <= #1 hp_d;
		rnd <= #1 rnd_d;
		MJ <= #1 MJ_d;
		ovf1 <= ovf1_d;
		ovf2 <= ovf2_d;

	end
end


always@(*) begin 
	if (sync2) begin
		 counter_d = 0;
                 flag_d = 0;
                 pusho_d = 0;
	 end else if (ovf1) begin
		counter_d = counter + 1;
			if (counter_d < 11'h3ff) begin

				flag_d = 0;

				pusho_d = 0;

			end else begin
				 pusho_d = 1;
				 flag_d = 1;
				 counter_d = 0;

				end
		end else begin
			counter_d = counter;

			if (counter_d < 11'h3ff) begin

                                flag_d = 0;

                                pusho_d = 0;

                        end else begin
                                 pusho_d = 1;
                                 flag_d = 1;
                                 counter_d = 0;

                                end
			end			
end	
			

correlator c1 (clk, reset, sync3, push_s4, MJ, flag1, samp4, corr1);

always@(*) begin
	sync1_d = sync;
	flag1_d = flag;
	pusho_1d = pusho;
	//sync2_d = sync1;
	sync3_d = sync2;
	push_s_d = push_samp;
	push_s2_d = push_s;
	push_s3_d = push_s2;
	push_s4_d = push_s3;
	samp1_d = samp;
	samp2_d = samp1;
	samp3_d = samp2;
	samp4_d = samp3;
end

always@(posedge(clk) or posedge(reset)) begin
	if (reset) begin
		sync1 <= 0;
		flag1 <= 0;
		dout1 <= 0;
	//	sync2 <= 0;
		sync3 <= 0;
		push_s <= 0;
		push_s2 <= 0;
		push_s3 <= 0;
		push_s4 <= 0;
		pusho_1 <= 0;
		flag <= 0;
		pusho <= 0;
		counter <= 0;

	end else begin
		sync1 <= #1 sync1_d;
		sync3 <= #1 sync3_d;
		dout1 <= #1 dout1_d;
		flag1 <= #1 flag1_d;
		push_s <= #1 push_s_d; 
		push_s2 <= #1 push_s2_d;
		push_s3 <= #1 push_s3_d;
		push_s4 <= #1 push_s4_d;
		pusho_1 <= #1 pusho_1d;
		samp1 <= #1 samp1_d;
		samp2 <= #1 samp2_d;
		samp3 <= #1 samp3_d;
		samp4 <= #1 samp4_d;
			flag <= #1 flag_d;
		pusho <= #1 pusho_d;
		counter <= #1 counter_d;

	end
end	
	

endmodule
