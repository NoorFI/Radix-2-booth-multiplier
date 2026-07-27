module tb_top;
    parameter N = 8;
    logic clk;
    logic rst;
    logic start_signal;
    logic signed [N-1:0] multiplicand;
    logic signed [N-1:0] multiplier;
    logic signed [2*N-1:0] product;
    logic done;
    logic signed [2*N-1:0] expected;
    
    integer pass_count = 0;
    integer fail_count = 0;
    
    radix2_booth_multiplier #(N) DUT(
        .clk(clk),
        .rst(rst),
        .start_signal(start_signal),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .done(done)
    );
    
    //Functional Coverage
    //covergroup cg;
    //  coverpoint multiplicand;
    //  coverpoint multiplier;
    //  coverpoint done;
    //endgroup
    //cg coverage = new();
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
    end
    
    task run_test( input logic signed [N-1:0] a, input logic signed [N-1:0] b);
        begin
        multiplicand = a;
        multiplier   = b;
        expected = $signed(a) * $signed(b);
    
        start_signal = 1;
        @(posedge clk);
        start_signal = 0;
        wait(done);
        #1;
        
        if(product === expected) begin
            $display("PASS : %0d x %0d = %0d", a, b, product);
            pass_count++;
        end
        else begin
            $display("FAIL : %0d x %0d", a, b);
            $display("Expected = %0d", expected);
            $display("Got = %0d", product);
            fail_count++;
        end
        
        @(posedge clk);
        //coverage.sample();
        end
    endtask
    
    //Assertions
    always @(posedge clk)
        begin
        if(done) begin
            assert(product === expected)
            else
            $error("Assertion Failed : Incorrect Product");
        end
        end
    
    initial begin
        rst = 1;
        start_signal = 0;
        multiplicand = 0;
        multiplier = 0;

        repeat(2) @(posedge clk);

        rst = 0;
        
        //Directed Tests
        run_test(5,3); //Positive, expected = +15
        run_test(-7,4); //Negative Positive, expected = -28
        run_test(-6,-2); //Negative, expected = +12
        run_test(0,25); //Zero, expected = 0
        run_test(25,0); //Zero, expected = 0
        
        //Corner Cases
        run_test(127,127); //Max positive, expected = +16,129
        run_test(-128,-1); //Max and min negative, expected = +128
        run_test(-128,127); //Boundary values, expected = -16,256
        run_test(-1,-1); //Min negative, expected = +1
        run_test(1,-128); //Boundary values, expected = -128
        
        //Random Tests
        repeat(500)
        begin
            run_test($random,$random);
        end
        
        //Summary
        $display("PASS = %0d",pass_count);
        $display("FAIL = %0d",fail_count);
    
        if(fail_count==0)
        $display("\nALL TESTS PASSED");
        else
        $display("\nSOME TESTS FAILED");
        
        $finish;
    end
endmodule