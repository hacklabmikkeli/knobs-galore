library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package common is
    constant freq_bits : natural := 16;
    constant freq_max : natural := 2**freq_bits;
    subtype freq_signal is unsigned(freq_bits - 1 downto 0);

    constant ctl_bits : natural := 8;
    constant ctl_max : natural := 2**ctl_bits;
    subtype ctl_signal is unsigned(ctl_bits - 1 downto 0);

    constant ampl_bits : natural := 12;
    constant ampl_max : natural := 2**ampl_bits;
    subtype ampl_signal is unsigned(ampl_bits - 1 downto 0);

    type pd_lut_t is array(0 to 63, 0 to 63) of ctl_signal;

    function pd_lookup(cutoff : ctl_signal
                      ;theta_in : ctl_signal
                      ;lut : pd_lut_t
                      )
    return ctl_signal;
end common;

package body common is
    function pd_lookup(cutoff : ctl_signal
                      ;theta_in : ctl_signal
                      ;lut : pd_lut_t
                      )
    return ctl_signal is
        constant shrink_factor : integer := (ctl_max / pd_lut_t'length(1));
        variable j : integer;
        variable i : integer;
        variable j1 : integer;
        variable i1 : integer;
        variable x : integer;
        variable y : integer;
        variable p1 : integer;
        variable p2 : integer;
        variable p3 : integer;
        variable p4 : integer;
        variable p12 : integer;
        variable p34 : integer;
        variable p1234 : integer;
    begin
        j := to_integer(cutoff) / shrink_factor;
        i := to_integer(theta_in) / shrink_factor;
        y := to_integer(cutoff) mod shrink_factor;
        x := to_integer(theta_in) mod shrink_factor;
        j1 := j + 1;
        i1 := i + 1;

        if j1 < pd_lut_t'low(1) then
            j1 := pd_lut_t'low(1);
        elsif j1 > pd_lut_t'high(1) then
            j1 := pd_lut_t'high(1);
        end if;

        if i1 < pd_lut_t'low(2) then
            i1 := pd_lut_t'low(2);
        elsif i1 > pd_lut_t'high(2) then
            i1 := pd_lut_t'high(2);
        end if;

        p1 := to_integer(lut(j, i));
        p2 := to_integer(lut(j, i1));
        p3 := to_integer(lut(j1, i));
        p4 := to_integer(lut(j1, i1));
        p12 := ((shrink_factor - x) * p1 + x * p2) / shrink_factor;
        p34 := ((shrink_factor - x) * p3 + x * p4) / shrink_factor;
        p1234 := ((shrink_factor - y) * p12 + y * p34) / shrink_factor;
        return to_unsigned(p1234, ctl_bits);
    end function;
end common;
