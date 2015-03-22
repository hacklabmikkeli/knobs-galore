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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity synthesizer_sim is
    port (CLK:              in  std_logic
         ;KEYS:             in  std_logic_vector(7 downto 0)
         ;AUDIO:            out ctl_signal
         )
    ;
end entity;

architecture synthesizer_sim_impl of synthesizer_sim is
    function keys_to_freq(keys : std_logic_vector(7 downto 0))
    return time_signal is
    begin
        case keys is
            when "00000001" => return to_unsigned(262, time_bits);
            when "00000010" => return to_unsigned(294, time_bits);
            when "00000100" => return to_unsigned(330, time_bits);
            when "00001000" => return to_unsigned(349, time_bits);
            when "00010000" => return to_unsigned(392, time_bits);
            when "00100000" => return to_unsigned(440, time_bits);
            when "01000000" => return to_unsigned(494, time_bits);
            when "10000000" => return to_unsigned(523, time_bits);
            when others     => return to_unsigned(0, time_bits);
        end case;
    end function;

    signal freq: time_signal := (others => '0');
    signal gate: std_logic;
    signal gain: ctl_signal;
    signal env_cutoff: time_signal;
    signal env_gain: time_signal;
    signal stage_cutoff: adsr_stage;
    signal stage_gain: adsr_stage;
    signal prev_gate_cutoff: std_logic;
    signal prev_gate_gain: std_logic;
    signal wave_sel: std_logic;
    signal theta : time_signal;

    signal voice_wf: waveform_t;
    signal voice_cutoff: ctl_signal;
    signal voice_theta: ctl_signal;
    signal voice_gain: ctl_signal;

    signal pd_theta: ctl_signal;
    signal pd_gain: ctl_signal;

    signal waveshaper_gain: ctl_signal;

    signal z: ctl_signal;
    signal z_ampl: ctl_signal;
begin

    gate <= '1' when KEYS /= "00000000" else '0';

    process (CLK)
    begin
        if rising_edge(CLK) then
            if gate = '1' then
                freq <= keys_to_freq(KEYS);
            end if;
        end if;
    end process;


    phase_gen:
        entity
            work.phase_gen (phase_gen_impl)
        port map
            ('1'
            ,CLK
            ,theta
            ,theta
            );

    env_gen_cutoff:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,CLK
            ,gate
            ,x"08"
            ,x"01"
            ,x"00"
            ,x"04"
            ,env_cutoff
            ,env_cutoff
            ,stage_cutoff
            ,stage_cutoff
            ,prev_gate_cutoff
            ,prev_gate_cutoff
            );

    env_gen_ampl:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,CLK
            ,gate
            ,x"08"
            ,x"01"
            ,x"00"
            ,x"02"
            ,env_gain
            ,env_gain
            ,stage_gain
            ,stage_gain
            ,prev_gate_gain
            ,prev_gate_gain
            );

    voice_controller:
        entity
            work.voice_controller (voice_controller_impl)
        port map
            ('1'
            ,CLK
            ,mode_saw_fat
            ,freq
            ,env_cutoff
            ,voice_cutoff
            ,env_gain
            ,voice_gain
            ,theta
            ,voice_theta
            ,voice_wf
            );


    phase_distort:
        entity 
            work.phase_distort (phase_distort_impl)
        port map
            ('1'
            ,CLK
            ,waveform_saw
            ,voice_cutoff
            ,voice_theta
            ,pd_theta
            ,voice_gain
            ,pd_gain
            );

    waveshaper:
        entity
            work.waveshaper(waveshaper_sin)
        port map
            ('1'
            ,CLK
            ,pd_theta
            ,z
            ,pd_gain
            ,waveshaper_gain
            );

    amplifier:
        entity
            work.amplifier (amplifier_impl)
        port map
            ('1'
            ,CLK
            ,waveshaper_gain
            ,z
            ,z_ampl
            );

    AUDIO <= z_ampl;
end architecture;
