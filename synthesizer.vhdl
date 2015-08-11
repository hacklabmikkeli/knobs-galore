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
    function key_to_freq(key: std_logic_vector(5 downto 0))
    return time_signal is
    begin
        case key is
            when "000000" => return to_unsigned(87, time_bits);
            when "000001" => return to_unsigned(92, time_bits);
            when "000010" => return to_unsigned(97, time_bits);
            when "000011" => return to_unsigned(103, time_bits);
            when "000100" => return to_unsigned(109, time_bits);
            when "000101" => return to_unsigned(116, time_bits);
            when "000110" => return to_unsigned(123, time_bits);
            when "000111" => return to_unsigned(130, time_bits);
            when "001000" => return to_unsigned(138, time_bits);
            when "001001" => return to_unsigned(146, time_bits);
            when "001010" => return to_unsigned(155, time_bits);
            when "001011" => return to_unsigned(164, time_bits);
            when "001100" => return to_unsigned(174, time_bits);
            when "001101" => return to_unsigned(184, time_bits);
            when "001110" => return to_unsigned(195, time_bits);
            when "001111" => return to_unsigned(206, time_bits);
            when "010000" => return to_unsigned(219, time_bits);
            when "010001" => return to_unsigned(232, time_bits);
            when "010010" => return to_unsigned(246, time_bits);
            when "010011" => return to_unsigned(260, time_bits);
            when "010100" => return to_unsigned(276, time_bits);
            when "010101" => return to_unsigned(292, time_bits);
            when "010110" => return to_unsigned(310, time_bits);
            when "010111" => return to_unsigned(328, time_bits);
            when "011000" => return to_unsigned(348, time_bits);
            when "011001" => return to_unsigned(368, time_bits);
            when "011010" => return to_unsigned(390, time_bits);
            when "011011" => return to_unsigned(413, time_bits);
            when "011100" => return to_unsigned(438, time_bits);
            when "011101" => return to_unsigned(464, time_bits);
            when "011110" => return to_unsigned(492, time_bits);
            when "011111" => return to_unsigned(521, time_bits);
            when "100000" => return to_unsigned(552, time_bits);
            when "100001" => return to_unsigned(585, time_bits);
            when "100010" => return to_unsigned(620, time_bits);
            when "100011" => return to_unsigned(656, time_bits);
            when "100100" => return to_unsigned(696, time_bits);
            when others  => return (others => '0');
        end case;
    end function;

    signal clk1: std_logic := '0';
    signal clk2: std_logic := '0';
    signal counter: unsigned(8 downto 0) := (others => '0');
    signal key_code: std_logic_vector(5 downto 0);
    signal key_event: key_event_t;
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

    process (CLK)
    begin
        if rising_edge(CLK) then
            if key_event = key_event_make then
                gate <= '1';
                freq <= key_to_freq(key_code);
            elsif key_event = key_event_break then
                gate <= '0';
                freq <= ('1', others => '0');
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

    phase_gen:
        entity
            work.phase_gen (phase_gen_impl)
        port map
            ('1'
            ,clk2
            ,theta
            ,theta
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
            ,x"80"
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
            ,clk2
            ,gate
            ,x"00"
            ,x"FF"
            ,x"40"
            ,x"02"
            ,x"FF"
            ,x"08"
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
            ,clk2
            ,mode_saw_res
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
