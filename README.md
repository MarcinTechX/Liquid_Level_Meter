# Liquid Level Meter Project

**Author:** MarcinTechX
---

## Project Overview

This project implements a liquid level measurement system in a tank. The liquid level is read from switches. An alarm is implemented, which triggers LED blinking if the liquid level is lower than the critical low level or higher than the critical high level.  

Critical levels can be adjusted by the user by simultaneously pressing two buttons:
- The mode switch button (switching between measurement and alarm setting modes)
- Either the low-level set button or the high-level set button  

When in the setting mode, the system stops measuring the liquid level. After releasing the buttons, the system resumes measurement and displays the liquid level as a percentage on three 7-segment displays.

---

## Module: `Liquid_Level_Meter`

### Parameters

- `SWITCHES_WIDTH` – Number of bits used to define the liquid level (maximum level is always a power of 2)  
- `LED_WIDTH` – Number of LEDs  
- `LED_COUNT_WIDTH` – Number of bits for the LED toggle counter  
- `LED_COUNT` – Number of clock cycles after which LEDs toggle during an alarm  

### Inputs

- `clk` – Clock signal  
- `switches` – Switches representing liquid level  
- `isMeasured` – Measurement mode (1 = measuring, 0 = setting alarm)  
- `set_low_level` – Set critical low level (active low)  
- `set_high_level` – Set critical high level (active low)  

### Outputs

- `seg1`, `seg2`, `seg3` – 7-segment display outputs (units, tens, hundreds of percentage)  
- `leds` – LEDs showing the alarm state  

### Internal Registers

- `led_state` – Current state of LEDs (1 = ON, 0 = OFF)  
- `alarm` – Alarm flag (1 = liquid level out of range)  
- `low_level`, `high_level` – Critical level registers  
- `bcd` – BCD representation of the liquid level for 7-segment display  
- `count` – Counter for LED toggling  

### Functionality

1. **Critical Level Setting**: Users can set low/high critical levels when `isMeasured` is 0.  
2. **Percentage Calculation**: Liquid level is converted to percentage using `(switches * 100) / (2^SWITCHES_WIDTH - 1)`.  
3. **BCD Conversion**: Implements the double-dabble algorithm for converting percentage to BCD for 7-segment displays.  
4. **Alarm Handling**: If liquid level is below `low_level` or above `high_level`, the `alarm` flag is set and LEDs blink.  
5. **LED Blinking**: The `led_state` toggles according to `LED_COUNT` cycles when the alarm is active.  
6. **Display Driving**: 7-segment displays show the liquid level percentage.

---

## Testbench: `Testbench`

### Purpose

The testbench simulates the `Liquid_Level_Meter` module to verify the functionality of:

- Liquid level measurement  
- Setting critical levels  
- Alarm triggering  
- LED blinking  

### Test Sequence

1. Initialize the clock and liquid level.  
2. Enter alarm setting mode (`isMeasured = 0`).  
3. Set critical low and high levels via switches.  
4. Return to measurement mode (`isMeasured = 1`).  
5. Change liquid level to test alarm triggering and LED blinking.  
6. Stop the simulation.

### Notes

- `LED_COUNT` is shortened to 3 for simulation purposes to quickly observe LED toggling.  
- `$monitor` and `$display` statements print all relevant internal signals and percentages for verification.

---

## How to Simulate

1. Compile both `Liquid_Level_Meter.v` and `Testbench.v` in your Verilog simulator.  
2. Run the simulation.  
3. Observe the console output and verify the LED and 7-segment display behavior according to the liquid level and alarm conditions.
