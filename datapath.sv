`timescale 1ns/1ps

//Datapath stores all registers, performs arithmetic and shifts. Then it tracks iteration count, produces Booth bits and final product.
module datapath #(parameter N = 8)(
    input logic clk,
    input logic rst,

    input logic signed [N-1:0] multiplicand,
    input logic signed [N-1:0] multiplier,

    input logic load,
    input logic run,
    input logic [1:0] control_signal,

    output logic [1:0] booth_bits,
    output logic signed [2*N-1:0] product,
    output logic [$clog2(N):0] count
);

    //ADD_M is easier to read than 3'd1 so we're defining local parameters.
    localparam NOP    = 2'd0;
    localparam ADD_M  = 2'd1;
    localparam SUB_M  = 2'd2;

  	logic signed [2*N+2:0] A;
    logic signed [N-1:0] Q;
    logic Qminus1;

  	logic signed [2*N+2:0] M_ext; //Sign-extended M

    logic [$clog2(N):0] counter;
    
  	logic signed [2*N+2:0] next_A;
  	logic signed [3*N+3:0] temp;

    assign booth_bits = {Q[0], Qminus1};
    assign count = counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            A <= '0;
            Q <= '0;
            Qminus1 <= 1'b0;
            M_ext <= '0;
            counter <= 0;
            product <= '0;
        end

        else if (load) begin
            A <= '0;
            Q <= multiplier;
            Qminus1 <= 1'b0;
          	M_ext <= {{(N+3){multiplicand[N-1]}}, multiplicand};
            counter <= N;
        end

        else if (run && counter != 0) begin
            next_A = A;
            //Arithmetic decision
            case (control_signal)
                ADD_M: next_A = A + M_ext;
                SUB_M: next_A = A - M_ext;
                default: next_A = A; //No change
            endcase

            //Radix2 Shift (1-bit arithmetic shift)
            temp = {next_A, Q, Qminus1};
            temp = temp >>> 1;
            {A, Q, Qminus1} <= temp;
            counter <= counter - 1;
        end
      
      	else if (run && counter == 0) begin
    		product <= {A[N-1:0], Q};  // Capture after all shifts done
		end
    end

endmodule