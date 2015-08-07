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
         ;KEYS_IN:          in  std_logic_vector(5 downto 0)
         ;LINE_LEFT_NEG:    out std_logic
         ;LINE_LEFT_POS:    out std_logic
         )
    ;
end entity;

architecture synthesizer_impl of synthesizer is
    function keys_to_freq( probe : std_logic_vector(2 downto 0)
                         ; keys : std_logic_vector(5 downto 0)
                         ; old : time_signal)
    return time_signal is
        variable combi: std_logic_vector(7 downto 0) := (others => '0');
    begin
        return old;
    end function;

    signal clk1: std_logic := '0';
    signal clk2: std_logic := '0';
    signal counter: unsigned(8 downto 0) := (others => '0');
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

    gate <= '1' when KEYS_IN /= "00000" else '0';

    with counter(2 downto 0) select
        KEYS_PROBE <= "1ZZZZZZZ" when "000",
                      "Z1ZZZZZZ" when "001",
                      "ZZ1ZZZZZ" when "010",
                      "ZZZ1ZZZZ" when "011",
                      "ZZZZ1ZZZ" when "100",
                      "ZZZZZ1ZZ" when "101",
                      "ZZZZZZ1Z" when "110",
                      "ZZZZZZZ1" when "111",
                      "ZZZZZZZZ" when others;

    process (CLK)
        begin
            if rising_edge(CLK) then
                if counter = to_unsigned(488, 9) then
                    counter <= "000000000";
                else
                    counter <= counter + 1;
            end if;

            if gate = '1' then
                freq <= keys_to_freq(counter(2 downto 0), KEYS_IN, freq);
            end if;
        end if;
    end process;

    clk1 <= CLK;
    clk2 <= '1' when counter = "000000000" else '0';

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
