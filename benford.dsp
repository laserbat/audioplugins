import("stdfaust.lib");

declare name "Benford Visualizer";
declare author "Olga Ustiuzhanina";
declare version "0.01";
declare license "GNU GPL 3.0";

declare description "A simple plugin to view frequency of initial digits of PCM samples.";

// UI declarations
alpha = hslider("alpha", 25, 0, 50, 0.01) : *(0.0001) : +(1) : log10;

graphs = hgroup("graph",
    par(i, 9, vbargraph("%j[style:numerical]", 0,1) with {j = i + 1;}));

// DSP code
first_digit = prepare : get with {
    prepare = abs <: _ * (_ < 1) * 10^9: floor;
    get = int(_ <: _ / 10 ^ int(log10));
};

// Exponential moving average implementation
exp_avg = (_ * (1 - alpha) + _ * alpha)~(_);
digit_counter(n) = ==(n) :  exp_avg;

// Main operation
digit_plotter = first_digit
    <: par(i, 9, digit_counter(i + 1)) : graphs
    :> /(2^64); // workaround to avoid this code getting optimized out

process = _, _ <: (+ : digit_plotter), (_, _) : _ + _, _;
