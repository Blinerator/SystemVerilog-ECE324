/* ECE 324 Homework6: Coin Detector
* Ilya Cable, 03/03/2024
File:  CoinDetector.sv

!!Changes to provided file begin at line 74!!

Revisions:
29 Dec 2018 Tom Pritchard: Initial version
*/
  
module CoinDetector 
	#(parameter dimeMin    = 380000, 
	            dimeMax    = 420000, 
				nickelMin  = 480000, 
				nickelMax  = 520000, 
				quarterMin = 580000, 
				quarterMax = 620000) 
   (input logic clk,
	input logic reset,
	input logic coinSensor,
	output logic dimeDetected=0, nickelDetected=0, quarterDetected=0
); 

//////////////////////////////////////////////////////////////////////////////////////////////
// Declarations			
logic sensorSync, sensor;
logic [20:0] coinTime, coinThresholdTime;
logic changeCoinTest;
logic [2:0] coinTest;

//////////////////////////////////////////////////////////////////////////////////////////////
// Synchronizer
always_ff @(posedge clk) begin
	sensorSync <= coinSensor; // synchronize to clock
	sensor <= sensorSync;     // for metastability
end

//////////////////////////////////////////////////////////////////////////////////////////////
// Timer
always_ff @(posedge clk) begin
	if (sensor == 0) coinTime <= 0;
	else             coinTime <= coinTime + 1;
end

//////////////////////////////////////////////////////////////////////////////////////////////
// Coin Threshold ROM
always_comb case (coinTest[2:0])
	0: coinThresholdTime = dimeMin;
	1: coinThresholdTime = dimeMax;
	2: coinThresholdTime = nickelMin;
	3: coinThresholdTime = nickelMax;
	4: coinThresholdTime = quarterMin;
	5: coinThresholdTime = quarterMax;
	default: coinThresholdTime = 21'bx; // oversize and idle states, not testing threshold
endcase

//////////////////////////////////////////////////////////////////////////////////////////////
// Comparator
always_comb changeCoinTest = (coinTime >= coinThresholdTime);

//////////////////////////////////////////////////////////////////////////////////////////////
// State Machine
typedef enum {testDmin, testDmax, testNmin, testNmax, testQmin, testQmax, oversize, idle} state_type;
state_type state, stateNext;
assign coinTest = state; // the states were assigned to generate the coinTest output bits directly

always_ff @(posedge clk) begin
	if (reset) state <= idle;
	else       state <= stateNext;
end

always_comb begin
	// defaults
	//stateNext = state;
	//dimeDetected = 0;
	// finish the state machine here
	case (state)
		testDmin: begin
			if(!changeCoinTest & sensor) stateNext = testDmin;			//Each state is approximately the same: check to see if changeCoinTest is high and if the sensor is still high. If yes, go to next state,
			else if(changeCoinTest & sensor) stateNext = testDmax;		//if not, stay in the same state. If the sensor goes low, go back to idle (and depending on the state, set a coin output high)
			else if(!sensor) stateNext = idle;
		end
		testDmax: begin
			if(!changeCoinTest & sensor) stateNext = testDmax;
			else if(changeCoinTest & sensor) stateNext = testNmin;
			else if(!sensor) begin 
				dimeDetected = 1; nickelDetected = 0; quarterDetected = 0;
				stateNext = idle;
			end
		end
		testNmin: begin
			if(!changeCoinTest & sensor) stateNext = testNmin;
			else if(changeCoinTest & sensor) stateNext = testNmax;
			else if(!sensor) stateNext = idle;
		end
		testNmax: begin
			if(!changeCoinTest & sensor) stateNext = testNmax;
			else if(changeCoinTest & sensor) stateNext = testQmin;
			else if(!sensor) begin
				nickelDetected = 1; dimeDetected = 0; quarterDetected = 0;
				stateNext = idle;
			end
		end
		testQmin: begin
			if(!changeCoinTest & sensor) stateNext = testQmin;
			else if(changeCoinTest & sensor) stateNext = testQmax;
			else if(!sensor) stateNext = idle;
		end
		testQmax: begin
			if(!changeCoinTest & sensor) stateNext = testQmax;
			else if(changeCoinTest & sensor) stateNext = oversize;
			else if(!sensor) begin
				quarterDetected = 1; dimeDetected = 0; nickelDetected = 0;
				stateNext = idle;
			end
		end
		oversize: begin
			if(sensor) stateNext = oversize;
			else stateNext = idle;
		end
		idle: begin												//Idle state
			if(sensor) stateNext = testDmin;
			else begin
				quarterDetected = 0; dimeDetected = 0; nickelDetected = 0;
				stateNext = idle; 
			end
		end
		default: stateNext = idle;									//Go to idle by default
	endcase
end

endmodule