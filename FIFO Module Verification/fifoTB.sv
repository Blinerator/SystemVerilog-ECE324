/************************************************
* ECE 324 Homework 5: FIFO Simulation
* Ilya Cable, 02/25/2024
* FIFO Testbench Module
************************************************/

// Set timescale for simulation
`timescale 1ns/10ps
parameter int data_width = 16;       
parameter int clock_period = 10;    //Set clock period 
int cc = 0;                //Counter for keeping track of how far into the sim we are
module fifoTB();
    logic clk = 0;                  //Start clock at low level
    logic reset = 1'b0;             //Reset is 0 by default
    logic rd = 0, wr, empty, full;
    logic [data_width-1:0] w_data, r_data;

    //Instantiate FIFO
    fifo #(.DATA_WIDTH(data_width),.ADDR_WIDTH(8)) UUT(
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .w_data(w_data),
        .empty(empty),
        .full(full),
        .r_data(r_data)
    );

    always #(clock_period/2) clk = ~clk;        //generate clock signal

    /*
    We need to test 4 things:
        1. Regular write to FIFO.
        2. Write when FIFO is full.
        3. Regular read from FIFO.
        4. Read when FIFO is empty.
        5. FIFO being empty and full concurrently.
        6. wr and rd pointers being the same when FIFO isn't empty or full.
    */
    logic [7:0] test_data = 16'b1111_1111_1111_1111;
    always @(posedge clk) begin
        ++cc;
        if(cc==1) reset = 1;
        else if(cc>1 && cc<260)begin     //fill the FIFO to test (1) & (2)
            reset = 0;
            wr = 1;
            w_data = test_data;
            --test_data;
        end
        else if(cc>260&&cc<270)rd=1;     //Read from FIFO to test (3)
        else if(cc==270)begin            //reset
            reset = 1; 
            wr = 0;
        end
        else if(cc>270 && cc<280)begin   //read empty FIFO to test (4)
            wr = 0;
            reset = 0;
            rd = 1;
        end
        else if(cc == 280)begin          //reset
            reset=1;
            rd=0;
        end
        else if(cc>280 && cc<285)begin   //set empty and full to '1' to test (5)
            reset = 0;
            fifo_ctrl.empty = 1;
            fifo_ctrl.full = 1;
        end
        else if(cc==285)begin            //reset
            fifo_ctrl.empty = 0;
            fifo_ctrl.full = 0;
            reset = 1;
        end
        else if(cc>286 && cc<290)begin   //write a few values to FIFO
            --test_data;
            reset = 0;
            wr = 1;
        end
        else if(cc>290&&cc<300)begin     //set write and read pointers equal to test (6)
            fifo_ctrl.w_addr=fifo_ctrl.r_addr;
        end 
    end
    initial #(300*clock_period) $finish; //stop sim after 300 clock cycles
endmodule