--
--    Knobs Galore - a free phase distortion synthesizer
--    Copyright (C) 2015 Ilmo Euro
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
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

    subtype adsr_stage is std_logic_vector(1 downto 0);
    constant adsr_attack:   adsr_stage      := "00";
    constant adsr_decay:    adsr_stage      := "01";
    constant adsr_sustain:  adsr_stage      := "10";
    constant adsr_rel:      adsr_stage      := "11";

    subtype waveform_t is std_logic;
    constant waveform_saw:  waveform_t      := '0';
    constant waveform_sq:   waveform_t      := '1';

    subtype mode_t is std_logic_vector(2 downto 0);
    constant mode_saw:      mode_t          := "000";
    constant mode_sq:       mode_t          := "001";
    constant mode_saw_res:  mode_t          := "010";
    constant mode_sq_res:   mode_t          := "011";
    constant mode_saw_fat:  mode_t          := "100";
    constant mode_sq_fat:   mode_t          := "101";
    constant mode_saw_sync: mode_t          := "110";
    constant mode_mix:      mode_t          := "111";

    type state_vector is
    record
        sv_phase1: time_signal;
        sv_phase2: time_signal;
        sv_wave_sel: std_logic;
        sv_ampl: time_signal;
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

    constant empty_state_vector : state_vector :=
        ((others => '0')
        ,(others => '0')
        ,'0'
        ,(others => '0')
        ,adsr_rel
        ,(others => '0')
        ,adsr_rel
        );

    -- TODO: make the array larger after optimizing
    type ctl_lut_t is array(0 to 255, 0 to 16) of ctl_signal;

    function to_ctl(input: time_signal)
    return ctl_signal;

    function to_audio_msb(input: ctl_signal)
    return audio_signal;

    function to_audio_lsb(input: ctl_signal)
    return audio_signal;
end common;

package body common is

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
end common;
