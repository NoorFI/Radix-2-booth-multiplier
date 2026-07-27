`timescale 1ns/1ps

//FSM controls sequencing, it has all states and their flow plus a counter. 
//It finds appropriate next state and monitors iteration counter to determine when multiplication is complete. 
module controller_fsm #(parameter N = 8)(
    input logic clk,
    input logic rst,
    input logic start_signal,

    input logic [$clog2(N):0] count,

    output logic load,
    output logic run,
    output logic busy,
    output logic done
);

//Defining FSM states
typedef enum logic [1:0] {
    IDLE  = 2'd0,
    LOAD_S  = 2'd1,
    RUN_S = 2'd2,
    DONE_S   = 2'd3
} state_t;

state_t state, next_state;

//State register
always_ff @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

//Next state logic
always_comb begin

    next_state = state;

    case (state)

        //Idle state is waiting for start
        IDLE: begin
            if (start_signal)
                next_state = LOAD_S;
        end

        //Load state is initializing datapath
        LOAD_S: begin
            next_state = RUN_S;
        end

        //RUN_S state is the core pipeline
        RUN_S: begin
            //Termination condition:
            if (count == 0)
                next_state = DONE_S;
        end

        //Done raises done signal after multiplication is finished 
        DONE_S: begin
            if (!start_signal)
                next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end

    endcase
end

always_comb begin

    //default outputs
    load = 1'b0;
    run = 1'b0;
    busy = 1'b0;
    done = 1'b0;

    case (state)
        IDLE: begin
        end

        LOAD_S: begin
            load = 1'b1; // LOAD
            busy = 1'b1;
        end

        RUN_S: begin
            run = 1'b1;
            busy = 1'b1;
        end

        DONE_S: begin
            done = 1'b1;
        end

        default: begin
        end

    endcase
end
endmodule