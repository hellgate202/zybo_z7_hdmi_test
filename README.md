Zybo Z7-20 HDMI TX Test
=======================

Example design to verify HDMI TX https://github.com/hellgate202/hdmi_tx and pattern generator https://github.com/hellgate202/axi4_video_pattern_gen
IP-cores

To build design project go to ./example directory and run:

    make build

To program board run:

    make prog

Known issues:

Pulse width slack on TMDS clock, because 742.5 MHz is not a joke.

Still works in hardware though.
