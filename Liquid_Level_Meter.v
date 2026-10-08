///////////////////////////////////////////////////////////////////////////////
/// Author: MarcinTechX
///////////////////////////////////////////////////////////////////////////////
/// This module measures the liquid level in a tank.
/// The liquid level is read from switches. An alarm is implemented, which
/// causes LEDs to blink if the water level is below the critical low level
/// or above the critical high level. Critical levels can be changed by the
/// user by holding two buttons simultaneously: one for switching from
/// simulation mode to alarm handling mode, and the other for setting the
/// low or high critical level. During this state, liquid level measurement
/// is paused. After releasing the buttons, the system resumes measuring
/// the liquid level and displays its percentage value on three 7-segment displays.
/////////////////////////////////////////////////////////////////////////////

module Miniprojekt #(
    parameter SWITCHES_WIDTH = 10, // Number of bits for liquid level (max level is always a power of 2)
    parameter LED_WIDTH = 10,      // Number of LEDs
    parameter LED_COUNT_WIDTH = 26, // Number of bits for LED toggle counter
    parameter LED_COUNT = 49999999  // Number of clock cycles after which LEDs toggle during alarm
)(
    input clk, // Clock
    input rst_n, // Asynchronous active-low reset
    input [SWITCHES_WIDTH - 1:0] switches, // Switches representing liquid level
    input isMeasured, // 1 = measuring, 0 = setting alarms
    input set_low_level, // 0 = user sets low critical level
    input set_high_level, // 0 = user sets high critical level
    output reg [6:0] seg1, // Units digit of percentage display
    output reg [6:0] seg2, // Tens digit of percentage display
    output reg [6:0] seg3, // Hundreds digit of percentage display
    output wire [LED_WIDTH - 1:0] leds, // LED indicators
    reg led_state, // LED state (1 = ON, 0 = OFF)
    reg alarm, // 1 = low or high liquid level alarm
    reg [SWITCHES_WIDTH - 1:0] low_level, // Low critical level
    reg [SWITCHES_WIDTH - 1:0] high_level, // High critical level
    wire [16:0] convert_to_percent // Stores percentage value (only last 7 bits used)
);

    reg [11:0] bcd; // BCD storage for 7-segment display
    reg [LED_COUNT_WIDTH - 1:0] count; // Counter for LED toggling

    // Initialize values
    initial begin
        count <= LED_COUNT - 1; // Initial counter value
        led_state <= 1'b0; // Initial LED state
        low_level <= 0; // Minimum liquid level
        high_level <= (1 << SWITCHES_WIDTH) - 1; // Maximum liquid level
    end

    // Set low critical level if button pressed and not measuring
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            low_level <= 0;
        else if (!set_low_level && !isMeasured)
            low_level <= switches;
        else
            low_level <= low_level;
    end

    // Set high critical level if button pressed and not measuring
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            high_level <= (1 << SWITCHES_WIDTH) - 1;
        else if (!set_high_level && !isMeasured)
            high_level <= switches;
        else
            high_level <= high_level;
    end

    // Calculate percentage value
    assign convert_to_percent = (switches * 100) / (2**SWITCHES_WIDTH - 1);

    integer i; // Loop variable

    // Convert percentage to BCD using double dabble algorithm
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bcd <= 0;
        else if (isMeasured) begin
            bcd = 0;
            for (i = 0; i < 7; i = i + 1) begin
                if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
                if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
                if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
                bcd = {bcd[10:0], convert_to_percent[6-i]};
            end
        end
        else
            bcd = bcd;
    end

    // Set alarm if liquid level is out of critical range
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            alarm <= 1'b0;
        else if (switches < low_level || switches > high_level)
            alarm <= 1;
        else
            alarm <= 0;
    end

    // LED blinking logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= LED_COUNT - 1;
            led_state <= 1'b0;
        end
        else if (alarm && isMeasured) begin
            if (count > 0)
                count <= count - 1;
            else begin
                count <= LED_COUNT - 1;
                led_state <= ~led_state;
            end
        end
        else
            count <= 0;
    end

    // Turn off LEDs if no alarm
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led_state = 0;
        else if (!alarm)
            led_state = 0;
        else
            led_state = led_state;
    end

    // Update 7-segment displays
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg1 <= ~7'b0000000;
            seg2 <= ~7'b0000000;
            seg3 <= ~7'b0000000;
        end
        else if (isMeasured) begin
            // Units
            case(bcd[3:0])
                4'b0000 : seg1 <= ~7'b0111111;
                4'b0001 : seg1 <= ~7'b0000110;
                4'b0010 : seg1 <= ~7'b1011011;
                4'b0011 : seg1 <= ~7'b1001111;
                4'b0100 : seg1 <= ~7'b1100110;
                4'b0101 : seg1 <= ~7'b1101101;
                4'b0110 : seg1 <= ~7'b1111101;
                4'b0111 : seg1 <= ~7'b0000111;
                4'b1000 : seg1 <= ~7'b1111111;
                4'b1001 : seg1 <= ~7'b1101111;
                default : seg1 <= ~7'b1111111;
            endcase

            // Tens
            case(bcd[7:4])
                4'b0000 : seg2 <= ~7'b0111111;
                4'b0001 : seg2 <= ~7'b0000110;
                4'b0010 : seg2 <= ~7'b1011011;
                4'b0011 : seg2 <= ~7'b1001111;
                4'b0100 : seg2 <= ~7'b1100110;
                4'b0101 : seg2 <= ~7'b1101101;
                4'b0110 : seg2 <= ~7'b1111101;
                4'b0111 : seg2 <= ~7'b0000111;
                4'b1000 : seg2 <= ~7'b1111111;
                4'b1001 : seg2 <= ~7'b1101111;
                default : seg2 <= ~7'b1111111;
            endcase

            // Hundreds
            case(bcd[11:8])
                4'b0000 : seg3 <= ~7'b0111111;
                4'b0001 : seg3 <= ~7'b0000110;
                4'b0010 : seg3 <= ~7'b1011011;
                4'b0011 : seg3 <= ~7'b1001111;
                4'b0100 : seg3 <= ~7'b1100110;
                4'b0101 : seg3 <= ~7'b1101101;
                4'b0110 : seg3 <= ~7'b1111101;
                4'b0111 : seg3 <= ~7'b0000111;
                4'b1000 : seg3 <= ~7'b1111111;
                4'b1001 : seg3 <= ~7'b1101111;
                default : seg3 <= ~7'b1111111;
            endcase
        end
        else begin
            seg1 <= ~7'b0000000;
            seg2 <= ~7'b0000000;
            seg3 <= ~7'b0000000;
        end
    end

    // Assign LED states
    assign leds[LED_WIDTH - 1:0] = {LED_WIDTH{led_state}};

endmodule