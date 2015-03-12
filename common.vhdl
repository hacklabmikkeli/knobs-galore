library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package common is
    constant ctl_bits : natural := 8;
    constant ctl_max : natural := 2**ctl_bits;
    subtype ctl_signal is unsigned(ctl_bits - 1 downto 0);

    constant time_bits : natural := 16;
    constant time_max : natural := 2**time_bits;
    subtype time_signal is unsigned(time_bits - 1 downto 0);

    constant audio_bits : natural := 13;
    constant audio_max : natural := 2**audio_bits;
    subtype audio_signal is unsigned(audio_bits - 1 downto 0);

    subtype adsr_stage is unsigned(1 downto 0);

    constant adsr_attack:   adsr_stage      := "00";
    constant adsr_decay:    adsr_stage      := "01";
    constant adsr_sustain:  adsr_stage      := "10";
    constant adsr_rel:      adsr_stage      := "11";
    constant foobar: std_logic := '1';

    type state_vector is
    record
        sv_phase1: time_signal;
        sv_phase2: time_signal; sv_wave_sel: std_logic; sv_ampl: time_signal;
        sv_ampl_stage: adsr_stage;
        sv_cutoff: time_signal;
        sv_cutoff_stage: adsr_stage;
    end record;

    type synthesis_params is
    record
        sp_amplitude_attack: ctl_signal;
        sp_amplitude_decay: ctl_signal;
        sp_amplitude_sustain: ctl_signal;
        sp_amplitude_rel: ctl_signal;
        sp_cutoff_base: ctl_signal;
        sp_cutoff_env: ctl_signal;
        sp_cutoff_attack: ctl_signal;
        sp_cutoff_decay: ctl_signal;
        sp_cutoff_sustain: ctl_signal;
        sp_cutoff_rel: ctl_signal;
    end record;
    
    constant num_voices : natural := 32;

    type pd_lut_t is array(0 to 63, 0 to 63) of ctl_signal;

    function pd_lookup(cutoff : ctl_signal
                      ;theta_in : ctl_signal
                      ;lut : pd_lut_t
                      )
    return ctl_signal;

    function to_ctl(input: time_signal)
    return ctl_signal;

    function to_audio_msb(input: ctl_signal)
    return audio_signal;

    function to_audio_lsb(input: ctl_signal)
    return audio_signal;

    function empty_state_vector
    return state_vector;
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

    function to_ctl(input: time_signal)
    return ctl_signal is
    begin
        return input(input'high downto input'high - ctl_bits + 1);
    end function;

    function to_audio_msb(input: ctl_signal)
    return audio_signal is
        variable retval: audio_signal := (others => '0');
    begin
        retval(retval'high downto retval'high - ctl_bits + 1) := input;
        return retval;
    end function;

    function to_audio_lsb(input: ctl_signal)
    return audio_signal is
        variable retval: audio_signal := (others => '0');
    begin
        retval(ctl_bits - 1 downto 0) := input;
        return retval;
    end function;

    function empty_state_vector
    return state_vector is
        variable retval: state_vector;
    begin
        retval.sv_phase1 := (others => '0');
        retval.sv_phase2 := (others => '0');
        retval.sv_wave_sel := '0';
        retval.sv_ampl := (others => '0');
        retval.sv_ampl_stage := (others => '0');
        retval.sv_cutoff := (others => '0');
        retval.sv_cutoff_stage := (others => '0');
        return retval;
    end function;
end common;
