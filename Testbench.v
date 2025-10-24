//////////////////////////////////////
/// Author: MarcinTechX
//////////////////////////////////////

`timescale 1ns/1ns

module Testbench;

    parameter SWITCHES_WIDTH = 10;
    parameter LED_WIDTH = 10;
    parameter LED_COUNT_WIDTH = 26;
    parameter LED_COUNT = 3; // Number of clock cycles after which LEDs toggle during alarm (shortened for testbench)

    reg clk;
    reg [SWITCHES_WIDTH - 1:0] switches;
    reg isMeasured;
    reg set_low_level;
    reg set_high_level;
    wire [6:0] seg1;
    wire [6:0] seg2;
    wire [6:0] seg3;
    wire [LED_WIDTH - 1:0] leds;

    wire led_state;
    wire alarm;
    wire low_level;
    wire high_level;
    wire convert_to_percent;

    Liquid_Level_Meter #(
        .SWITCHES_WIDTH(SWITCHES_WIDTH),
        .LED_WIDTH(LED_WIDTH),
        .LED_COUNT_WIDTH(LED_COUNT_WIDTH),
        .LED_COUNT(LED_COUNT)
    )
    tb_instance (
        .clk(clk),
        .switches(switches),
        .isMeasured(isMeasured),
        .set_low_level(set_low_level),
        .set_high_level(set_high_level),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .leds(leds),
        .led_state(led_state),
        .alarm(alarm),
        .low_level(low_level),
        .high_level(high_level),
        .convert_to_percent(convert_to_percent)
    );

    always #10 clk = ~clk;

    initial begin
        $monitor("@ %0t ns: Liquid level: %0d, isMeasured: %b", $time, switches, isMeasured,
                " Critical low level: %b, Critical high level: %b", low_level, high_level,
                " Alarm: %b, LED state: %b, Percent liquid level: %0d", alarm, led_state, (switches * 100) / (2**SWITCHES_WIDTH - 1));

        $display("Minimum liquid level: %0d", 0);
        $display("Maximum liquid level: %0d", (1 << SWITCHES_WIDTH) - 1);

        clk = 0;
        $display("@ %0t ns: Simulation started", $time);
        switches = 10'b1000000000;
        $display("@ %0t ns: Initial liquid level: %0d", $time, switches);
        #15 isMeasured = 1'b0;
        $display("@ %0t ns: Entering alarm setting mode", $time);
        set_low_level = 1'b0;
        switches = 10'b0000001000;
        $display("@ %0t ns: Setting critical low level to %0d", $time, switches);
        #50 set_low_level = 1'b1;
        set_high_level = 1'b0;
        switches = 10'b1100000000;
        $display("@ %0t ns: Setting critical high level to %0d", $time, switches);
        #15 set_high_level = 1'b1;
        #10 isMeasured = 1'b1;
        $display("@ %0t ns: Returning to liquid level measurement", $time);
        #10 switches = 10'b1111111111;
        $display("@ %0t ns: Liquid level value: %0d", $time, switches);
        #450 switches = 10'b0000100000;
        $display("@ %0t ns: Liquid level value: %0d", $time, switches);
        #200 switches = 10'b0000000001;
        $display("@ %0t ns: Liquid level value: %0d", $time, switches);
        #300 $stop;
    end

endmodule
