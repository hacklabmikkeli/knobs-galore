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

entity synthesizer is
    port (CLK:              in  std_logic
         ;KEYS_PROBE:       out std_logic_vector(7 downto 0)
         ;KEYS_IN:          in  std_logic_vector(4 downto 0)
         ;LINE_LEFT_NEG:    out std_logic
         ;LINE_LEFT_POS:    out std_logic
         )
    ;
end entity;

architecture synthesizer_impl of synthesizer is

    signal clk1: std_logic := '0';
    signal clk2: std_logic := '0';
    signal counter: unsigned(8 downto 0) := (others => '0');
    signal key_code: keys_signal;
    signal key_event: key_event_t;
    signal freq: time_signal := (others => '0');
    signal gate: std_logic;

    signal state_vector_front: state_vector_t := empty_state_vector;
    signal state_vector_back: state_vector_t := empty_state_vector;

    signal voice_wf: waveform_t;
    signal voice_cutoff: ctl_signal;
    signal voice_theta: ctl_signal;
    signal voice_gain: ctl_signal;

    signal pd_theta: ctl_signal;
    signal pd_gain: ctl_signal;

    signal waveshaper_gain: ctl_signal;

    signal z: ctl_signal;
    signal z_ampl: ctl_signal;
    signal v_out: std_logic;
begin

    process (CLK)
    begin
        if rising_edge(CLK) then
            if counter = to_unsigned(488, 9) then
                counter <= "000000000";
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk1 <= CLK;
    clk2 <= '1' when counter = "000000000" else '0';

    input_buffer:
        entity
            work.input_buffer (input_buffer_impl)
        port map
            ('1'
            ,clk2
            ,KEYS_IN
            ,KEYS_PROBE
            ,key_code
            ,key_event
            ,open
            );

    voice_allocator:
        entity
            work.voice_allocator (voice_allocator_impl)
        port map
            ('1'
            ,clk2
            ,key_code
            ,key_event
            ,freq
            ,gate
            );

    circular_buffer:
        entity
            work.circular_buffer (circular_buffer_impl)
        port map
            ('1'
            ,clk2
            ,state_vector_back
            ,state_vector_front
            );

    phase_gen:
        entity
            work.phase_gen (phase_gen_impl)
        port map
            ('1'
            ,clk2
            ,state_vector_front.sv_phase
            ,state_vector_back.sv_phase
            );

    env_gen_cutoff:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,clk2
            ,gate
            ,x"00"
            ,x"F0"
            ,x"E8"
            ,x"10"
            ,x"00"
            ,x"04"
            ,state_vector_front.sv_cutoff
            ,state_vector_back.sv_cutoff
            ,state_vector_front.sv_cutoff_stage
            ,state_vector_back.sv_cutoff_stage
            ,state_vector_front.sv_cutoff_prev_gate
            ,state_vector_back.sv_cutoff_prev_gate
            );

    env_gen_gain:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,clk2
            ,gate
            ,x"00"
            ,x"FF"
            ,x"40"
            ,x"02"
            ,x"FF"
            ,x"08"
            ,state_vector_front.sv_gain
            ,state_vector_back.sv_gain
            ,state_vector_front.sv_gain_stage
            ,state_vector_back.sv_gain_stage
            ,state_vector_front.sv_gain_prev_gate
            ,state_vector_back.sv_gain_prev_gate
            );

    voice_controller:
        entity
            work.voice_controller (voice_controller_impl)
        port map
            ('1'
            ,clk2
            ,mode_saw_res
            ,freq
            ,state_vector_front.sv_cutoff
            ,voice_cutoff
            ,state_vector_front.sv_gain
            ,voice_gain
            ,state_vector_front.sv_phase
            ,voice_theta
            ,voice_wf
            );


    phase_distort:
        entity 
            work.phase_distort (phase_distort_impl)
        port map
            ('1'
            ,clk2
            ,voice_wf
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
            ,clk2
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
            ,clk2
            ,waveshaper_gain
            ,z
            ,z_ampl
            );

	dac:
        entity 
            work.delta_sigma_dac(delta_sigma_dac_impl)
        port map
            ('1'
            ,clk1
            ,to_audio_msb(z_ampl)
            ,v_out
            );

    LINE_LEFT_NEG <= not v_out;
    LINE_LEFT_POS <= v_out;
end architecture;
