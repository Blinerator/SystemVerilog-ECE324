Tests a provided FIFO module to verify proper functioning.
- fifo.sv, fifo_ctrl.sv, reg_file.sv: Modules to be tested (provided)
- fifoTB.sv: Testbench for the above. Assertions are implemented in fifo_ctrl.sv, so the testbench just needs to go through all signal possibilities and test some impossible configurations, such as the read and write pointers being equal when the FIFO isn't full or empty.
