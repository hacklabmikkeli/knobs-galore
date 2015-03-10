library ieee;
library std;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

use work.common.all;

entity phase_distort is
    port    (CLK:           in  std_logic
            ;CUTOFF:        in  ctl_signal
            ;THETA_IN:      in  ctl_signal
            ;THETA_OUT:     out ctl_signal
            )
    ;
end entity;

architecture phase_distort_saw of phase_distort is
    function transfer(cutoff : integer
                     ;x : integer
                     )
    return integer is
        variable y0 : integer;
        variable y : integer;
        variable k : integer;

    begin
        k := cutoff / 2;
        y0 := (ctl_max / 2) - k;
        if x < k then
            y := (x * y0) / k;
        else
            y := y0 - ((x-k) * y0) / (ctl_max - k);
        end if;
        y := y + x;
        return y mod ctl_max;
    end function;

    function make_lut return pd_lut_t is
        constant shrink_factor : integer := (ctl_max / pd_lut_t'length(1));
        variable result : pd_lut_t;

    begin
        for j in pd_lut_t'low(1) to pd_lut_t'high(1) loop
            for i in pd_lut_t'low(2) to pd_lut_t'high(2) loop
                result(j,i) := to_unsigned(transfer(j*shrink_factor,
                                                    i*shrink_factor),ctl_bits);
            end loop;
        end loop;
        return result;
    end function;

    constant lut : pd_lut_t := make_lut;
    
    signal theta_out_buf: ctl_signal := (others => '0');
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            theta_out_buf <= pd_lookup(CUTOFF, THETA_IN, lut);
        end if;
    end process;

    THETA_OUT <= theta_out_buf;
end architecture;

architecture phase_distort_sq of phase_distort is
    function transfer(cutoff : integer
                     ;x : integer
                     )
    return integer is
        variable k : integer;
        variable y0 : integer;
        variable y : integer;

    begin
        k := cutoff / 4;
        y0 := ctl_max / 4;
        if x < k then
            y := (x * y0) / k;
        elsif x < (ctl_max / 2) - k then
            y := y0;
        elsif x < (ctl_max / 2) + k then
            y := y0 + (x + k - (ctl_max / 2)) * y0 / k;
        elsif x < ctl_max - k then
            y := (ctl_max / 2) + y0;
        else
            y := (ctl_max / 2) + y0 + (x + k - ctl_max) * y0 / k;
        end if;
        return y mod ctl_max;
    end function;

    function make_lut return pd_lut_t is
        constant shrink_factor : integer := (ctl_max / pd_lut_t'length(1));
        variable result : pd_lut_t;

    begin
        for j in pd_lut_t'low(1) to pd_lut_t'high(1) loop
            for i in pd_lut_t'low(2) to pd_lut_t'high(2) loop
                result(j,i) := to_unsigned(transfer(j*shrink_factor,
                                                    i*shrink_factor),ctl_bits);
            end loop;
        end loop;
        return result;
    end function;

    constant lut : pd_lut_t := make_lut;

    signal theta_out_buf: ctl_signal := (others => '0');
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            theta_out_buf <= pd_lookup(CUTOFF, THETA_IN, lut);
        end if;
    end process;

    THETA_OUT <= theta_out_buf;
end architecture;
