Implements a state machine for detecting what coin (dime, nickel, or quarter) has been inserted to a coin slot.

A sensor (13) is normally low, until light from a diode (11) is blocked by the coin, at which point the sensor goes high. How long the sensor remains high is determined by the diameter of the coin, allowing us to determine its value.


![image](https://github.com/Blinerator/SystemVerilog-ECE324-/assets/107442543/26b77374-c48d-4827-b7c5-4530f90f4b2e)

- CoinDetector.sv: Implements an 8-state finite state machine to determine coin.
- CoinDetectorTB.sv: Testbench for the above. Tests all input permutations and implements assertions if irregular outputs are detected.
