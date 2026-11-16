`timescale 1ns/1ps
module ALU (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] instruction,
    output reg  [7:0] F            
);
 //TODO: write your design below

integer i;
integer found;
integer k;

always @(*) begin
    F = 8'b0;

    case (instruction)

        4'b0000: begin
            // Right Rotate
            F=(A>>B) | (A<<(8-B));
        end

        4'b0001: begin
            // Left Rotate
	    F=(A<<B) | (A>>(8-B));
        end

        4'b0010: begin
            // Population Count
	    F=8'd0;
	    for (i=0; i<8; i=i+1) begin
		if (A[i]==1'b1)
		    F=F+1'b1;
	    end
        end

        4'b0011: begin
	    // Absolute Difference		
            if (A>=B)
		F=A-B;
	    else
		F=B-A;
        end

        4'b0100: begin
            // Leading Zero Count
	    F=8'd0;
	    found=0;
	    for (i=7; i>=0; i=i-1) begin
		if (found==0) begin
		    if (A[i]==1'b0)
			F=F+1'b1;
		    else
			found=1;
		end
	    end
        end

        4'b0101: begin
	    // Saturated Add
            if ({1'b0, A} + {1'b0, B}>9'd255)
		F=8'd255;
	    else
		F=A+B;
        end

        4'b0110: begin
            // ResetTailk
	    F=A;
	    k=0;
	    for (i=0; i<8; i=i+1) begin
		if (B[i]==1'b1)
		    k=k+1;
	    end
	    
	    for (i=0; i<8; i=i+1) begin
		if (i<k)
		    F[i]=1'b0;
	    end
        end

        4'b0111: begin
            // SetTailk
            F=A;
            k=0;
            for (i=0; i<8; i=i+1) begin
                if (B[i]==1'b1)
                    k=k+1;
            end

            for (i=0; i<8; i=i+1) begin
                if (i<k)
                    F[i]=1'b1;
            end

        end

        4'b1000: begin
	    // XOR
            F = A^B;
        end

        4'b1001: begin
	    // ADD
            F=A+B;
        end

        4'b1010: begin
	    // SUB
            F=A-B;
        end

        default: begin
            F=8'b0;
        end

    endcase
end

endmodule
