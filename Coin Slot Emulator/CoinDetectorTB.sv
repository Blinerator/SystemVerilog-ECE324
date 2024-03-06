/************************************************
* ECE 324 Homework 6: FSM Design and Simulation
* Ilya Cable, 03/03/2024
* Coin Detector Testbench module
************************************************/

// Set timescale for sim
`timescale 1ns/10ps

parameter int clock_period = 10;                 // Set clock period 
int cc = 0;                                     // Counter for keeping track of how far into the sim
module CoinDetectorTB();
    logic clk = 0, reset = 0, coinSensor=0;
    logic dimeDetected, nickelDetected, quarterDetected;
    CoinDetector #(.dimeMin(2), .dimeMax(4), .nickelMin(6), .nickelMax(8), .quarterMin(10), .quarterMax(12)) UUT(
        .clk(clk),
        .reset(reset),
        .coinSensor(coinSensor),
        .dimeDetected(dimeDetected),
        .nickelDetected(nickelDetected),
        .quarterDetected(quarterDetected)
    );

    always #(clock_period/2) clk = ~clk;        // Generate clock signal
    always @(posedge clk) begin
        ++cc;
        if(cc==1) reset = 1;

        //Test Dime:
        else if(cc==2) begin
            reset = 0;
            coinSensor = 1;
            assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!");       //Test less than Dmin
        end
        else if(cc == 3) begin 
            coinSensor = 0;
            assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!");          
        end
        else if(cc >= 4 && cc < 7) begin 
            coinSensor = 1;
            assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!");       //Test a dime inserted
        end
        else if(cc == 7) begin 
            coinSensor = 0;
            assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!");                
        end
        //Test Nickel
        else if(cc >= 8 && cc < 13) begin
            coinSensor = 1;
            #5 assert(dimeDetected & !(nickelDetected | quarterDetected)) else $warning("Only a dime should be detected!"); //Test less than Nmin
        end
        else if(cc == 13) begin
            coinSensor = 0;
            assert(dimeDetected & !(nickelDetected | quarterDetected)) else $warning("Only a dime should be detected!");              
        end
        else if(cc >= 14 && cc < 21) begin
            coinSensor = 1;
            #5 assert(dimeDetected & !(nickelDetected | quarterDetected)) else $warning("Only a dime should be detected!"); //Test a nickel inserted
        end
        else if(cc == 21) begin
            coinSensor = 0;
            assert(dimeDetected & !(nickelDetected | quarterDetected)) else $warning("Only a dime should be detected!");                
        end
        //Test Quarter:
        else if(cc >= 22 && cc < 32) begin
            coinSensor = 1;
            #5 assert(nickelDetected & !(dimeDetected | quarterDetected)) else $warning("Only a nickel should be detected!");//Test less than Qmin
        end
        else if(cc == 32) begin
            coinSensor = 0;
            assert(nickelDetected & !(dimeDetected | quarterDetected)) else $warning("Only a nickel should be detected!");                 
        end
        else if(cc >= 33 && cc < 45) begin
            coinSensor = 1;
            #5 assert(nickelDetected & !(dimeDetected | quarterDetected)) else $warning("Only a nickel should be detected!");//Test quarter inserted
        end
        else if(cc == 45) begin
            coinSensor = 0;
            assert(nickelDetected & !(dimeDetected | quarterDetected)) else $warning("Only a nickel should be detected!");
        end
        else if(cc >= 45 && cc<47) #5 assert(quarterDetected & !(dimeDetected | nickelDetected)) else $warning("Only a quarter should be detected!");
        else if(cc>46 && cc < 50) #5 assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!"); //Test oversize
        else if(cc == 50) reset = 1;
        else if(cc > 50) begin
            reset = 0;
            coinSensor = 1;
            #5 assert(!(dimeDetected | nickelDetected | quarterDetected)) else $warning("No coins should be detected!");
        end
    end
    initial #(70*clock_period) $finish;
endmodule