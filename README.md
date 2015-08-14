# Floating Point Unit

This repo contains the floating point datapath of the
[Artemis](http://asic.ee.ethz.ch/2014/Artemis.html) chip. It supports
single-precision (32 bit) addition and multiplication with several rounding
modes. The implementation follows the IEEE-754 standard, but does not implement
all rounding modes.

It is intended to be used as part of OR10N/RI5CY, where one operation should be
split up into two cycles for timing reasons.

