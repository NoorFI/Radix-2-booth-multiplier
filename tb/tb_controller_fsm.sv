`timescale 1ns/1ps

module tb_controller_fsm;
    parameter N = 8;
    logic clk;
    logic rst;
    logic start_signal;
    logic [$clog2(N):0] count;
    logic load;
    logic run;
    logic busy;
    logic done;

    integer pass_count = 0;
    integer fail_count = 0;

    controller_fsm #(N) DUT (
      .clk(clk),
      .rst(rst),
      .start_signal(start_signal),
      .count(count),
      .load(load),
      .run(run),
      .busy(busy),
      .done(done)
    );
  
    initial begin
      clk = 0;
      forever #5 clk = ~clk;
    end
  
  	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_controller_fsm);
	end
  
    initial begin
      rst = 1;
      start_signal = 0;
      count = 0;
      
      //Test 1: Reset
      #12;
      rst = 0;

      @(posedge clk);
      #1;

      if (!load && !run && !busy && !done) begin
        $display("PASS : Reset places FSM in IDLE.");
        pass_count++;
      end
      else begin
        $error("FAIL : FSM not in IDLE after reset.");
        fail_count++;
      end
      
      //Test 2: LOAD State
      start_signal = 1;
      @(posedge clk);
      #1;

      if (load && busy && !run && !done) begin
        $display("PASS : LOAD state outputs correct.");
        pass_count++;
      end
      else begin
        $error("FAIL : Incorrect LOAD state outputs.");
        fail_count++;
      end

      start_signal = 0;
      
      //Test 3: RUN State
      count = N;
      @(posedge clk);
      #1;
      
      if (run && busy && !load && !done) begin
        $display("PASS : RUN state entered.");
        pass_count++;
      end
      else begin
        $error("FAIL : RUN state incorrect.");
        fail_count++;
      end
      
      //Test 4: Stay in RUN State
      count = 5;
      @(posedge clk);
      #1;
      
      if (run && busy && !done) begin
        $display("PASS : FSM remains in RUN while count > 0.");
        pass_count++;
      end
      else begin
        $error("FAIL : FSM left RUN too early.");
        fail_count++;
      end
      
      //Test 5: DONE State
      count = 0;
      @(posedge clk);
      #1;
      
      if (done && !busy && !run && !load) begin
        $display("PASS : DONE asserted correctly.");
        pass_count++;
      end
      else begin
        $error("FAIL : DONE state incorrect.");
        fail_count++;
      end
      
      //Test 6: Return to IDLE
      @(posedge clk);
      #1;
      
      if (!load && !run && !busy && !done) begin
        $display("PASS : Returned to IDLE.");
        pass_count++;
      end
      else begin
        $error("FAIL : FSM failed to return to IDLE.");
        fail_count++;
      end
      
      //Simulation Summary
      $display(" Controller FSM Verification Summary");
      $display("PASS = %0d", pass_count);
      $display("FAIL = %0d", fail_count);

      if (fail_count == 0)
        $display("All Controller FSM tests passed.");
      else
        $display("Controller FSM test failed.");

      #10;
      $finish;
    end
endmodule