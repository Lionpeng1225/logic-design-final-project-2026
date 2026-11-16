`timescale 1ns/1ps
module top #(parameter K = 3) (
    input clk,
    input rst_n,
    input start,
    input valid,
    input [7:0] data_A,
    input [7:0] data_B,
    input [3:0] instruction,
    input [7:0] count,
    output [7:0] kth_largest,
    output finish
);
   //TODO: write your design below
wire [7:0] alu_result;

reg [7:0] kth_largest_reg;
reg finish_reg;

reg [7:0] target_count;
reg [7:0] received_count;

reg [7:0] largest1;
reg [7:0] largest2;
reg [7:0] largest3;
reg [7:0] largest4;
reg [7:0] largest5;

reg [7:0] next_largest1;
reg [7:0] next_largest2;
reg [7:0] next_largest3;
reg [7:0] next_largest4;
reg [7:0] next_largest5;

assign kth_largest = kth_largest_reg;
assign finish = finish_reg;

ALU alu_inst (
    .A(data_A),
    .B(data_B),
    .instruction(instruction),
    .F(alu_result)
);

always @(*) begin
    next_largest1 = largest1;
    next_largest2 = largest2;
    next_largest3 = largest3;
    next_largest4 = largest4;
    next_largest5 = largest5;

    if (alu_result >= largest1) begin
        next_largest1 = alu_result;
        next_largest2 = largest1;
        next_largest3 = largest2;
        next_largest4 = largest3;
        next_largest5 = largest4;
    end
    else if (alu_result >= largest2) begin
        next_largest2 = alu_result;
        next_largest3 = largest2;
        next_largest4 = largest3;
        next_largest5 = largest4;
    end
    else if (alu_result >= largest3) begin
        next_largest3 = alu_result;
        next_largest4 = largest3;
        next_largest5 = largest4;
    end
    else if (alu_result >= largest4) begin
        next_largest4 = alu_result;
        next_largest5 = largest4;
    end
    else if (alu_result >= largest5) begin
        next_largest5 = alu_result;
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        kth_largest_reg <= 8'd0;
        finish_reg       <= 1'b0;
        target_count     <= 8'd0;
        received_count   <= 8'd0;

        largest1 <= 8'd0;
        largest2 <= 8'd0;
        largest3 <= 8'd0;
        largest4 <= 8'd0;
        largest5 <= 8'd0;
    end
    else begin
        finish_reg <= 1'b0;

        if (start) begin
            target_count   <= count;
            received_count <= 8'd0;

            largest1 <= 8'd0;
            largest2 <= 8'd0;
            largest3 <= 8'd0;
            largest4 <= 8'd0;
            largest5 <= 8'd0;
        end
	else if (valid) begin
            largest1 <= next_largest1;
   	    largest2 <= next_largest2;
   	    largest3 <= next_largest3;
   	    largest4 <= next_largest4;
   	    largest5 <= next_largest5;

   	    received_count <= received_count + 8'd1;

   	    if (received_count + 8'd1 == target_count) begin
                case (K)
                    1: kth_largest_reg <= next_largest1;
                    2: kth_largest_reg <= next_largest2;
                    3: kth_largest_reg <= next_largest3;
                    4: kth_largest_reg <= next_largest4;
                    5: kth_largest_reg <= next_largest5;
                    default: kth_largest_reg <= 8'd0;
                endcase

	        finish_reg <= 1'b1;
	    end
        end
    end
end
endmodule
