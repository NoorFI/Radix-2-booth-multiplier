`timescale 1ns/1ps

//This is the top module, it connects FSM with datapath.
module radix2_booth_multiplier #(parameter N = 8)(
    input logic clk,
    input logic rst,
    input logic start_signal,

    input logic signed [N-1:0] multiplicand,
    input logic signed [N-1:0] multiplier,

    output logic signed [2*N-1:0] product,
    output logic done
);
    //Internal interconnected wires
    logic load;
    logic run;
    logic busy;
    logic [1:0] opcode;
    logic [1:0] booth_bits;
    logic [$clog2(N):0] count;

    //FSM instantiation
    controller_fsm #(N) CU (
        .clk(clk),
        .rst(rst),
        .start_signal(start_signal),

        .count(count),

        .load(load),
        .run(run),
        .busy(busy),
        .done(done)
    );
    
     //Booth Encoder instantiation
    booth_encoder BD (
        .booth_bits(booth_bits),
        .opcode(opcode)
    );

    //Datapath instantiation
    datapath #(N) DP (
        .clk(clk),
        .rst(rst),

        .multiplicand(multiplicand),
        .multiplier(multiplier),

        .load(load),
        .run(run),
        .control_signal(opcode),

        .booth_bits(booth_bits),
        .product(product),
        .count(count)
    );
    
endmodule