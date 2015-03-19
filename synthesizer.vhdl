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
         ;KEYS:             in  std_logic_vector(7 downto 0)
         ;LINE_LEFT_POS:    out std_logic
         ;LINE_LEFT_NEG:    out std_logic
         )
    ;
end entity;

architecture synthesizer_impl of synthesizer is
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

    signal clk1: std_logic := '0';
    signal clk2: std_logic := '0';
    signal counter: unsigned(8 downto 0) := (others => '0');
    signal freq: time_signal := (others => '0');
    signal gate: std_logic := '0';
    signal gain: ctl_signal := (others => '0');
    signal env_cutoff: time_signal := (others => '0');
    signal env_gain: time_signal := (others => '0');
    signal stage_cutoff: adsr_stage := adsr_rel;
    signal stage_gain: adsr_stage := adsr_rel;
    signal prev_gate_cutoff: std_logic := '0';
    signal prev_gate_gain: std_logic := '0';
    signal wave_sel: std_logic := '0';
    signal theta: time_signal := (others => '0');
    signal theta_pd: ctl_signal := (others => '0');
    signal z: ctl_signal := (others => '0');
    signal z_ampl: ctl_signal := (others => '0');
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
            if gate = '1' then
                freq <= keys_to_freq(KEYS);
            end if;
        end if;
    end process;

    clk1 <= CLK;
    clk2 <= '1' when counter = "000000000" else '0';
    gate <= '1' when KEYS /= "00000000" else '0';

    phase_gen:
        entity
            work.phase_gen (phase_gen_impl)
        port map
            ('1'
            ,clk2
            ,freq
            ,theta
            ,theta
            ,wave_sel
            ,wave_sel
            );

    env_gen_cutoff:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,clk2
            ,gate
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
            ,x"80"
            ,x"08"
            ,x"FF"
            ,x"02"
            ,env_gain
            ,env_gain
            ,stage_gain
            ,stage_gain
            ,prev_gate_gain
            ,prev_gate_gain
            );

    phase_distort:
        entity 
            work.phase_distort (phase_distort_impl)
        port map
            ('1'
            ,clk2
            ,waveform_saw
            ,env_cutoff(15 downto 8)
            ,theta(15 downto 8)
            ,theta_pd
            -- TODO: hook up gain to signal pipeline
            ,(others => '0')
            ,open
            );

    waveshaper:
        entity
            work.waveshaper(waveshaper_sin)
        port map
            ('1'
            ,clk2
            ,theta_pd
            ,z
            ,(others => '0')
            ,open
            );

    delay:
        entity
            work.delay (delay_impl)
        port map
            ('1'
            ,clk2
            ,env_gain(15 downto 8)
            ,gain
            );

    amplifier:
        entity
            work.amplifier (amplifier_impl)
        port map
            ('1'
            ,clk2
            ,gain
            ,z
            ,z_ampl
            );

	dac : entity 
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
