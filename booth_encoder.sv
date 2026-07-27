`timescale 1ns/1ps

//Booth encoder basically takes the pair as input and outputs the appropriate operation to be performed.
module booth_encoder(
    input  logic [1:0] booth_bits,
    output logic [1:0] opcode
);

//ADD_M is easier to read than 3'd1 so we're defining local parameters.
localparam NOP    = 2'd0;
localparam ADD_M  = 2'd1;
localparam SUB_M  = 2'd2;

//Combinational logic, it has nothing to do with clock.
always_comb begin
    case (booth_bits)
        2'b00 : opcode = NOP;
        2'b01 : opcode = ADD_M;
        2'b10 : opcode = SUB_M;
        2'b11 : opcode = NOP;
        default: opcode = NOP;
    endcase
end
endmodule