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
         ;KEYS_PROBE:       out std_logic_vector(4 downto 0)
         ;KEYS_IN:          in  std_logic_vector(7 downto 0)
         ;CPANEL_PROBE:     out std_logic_vector(4 downto 0)
         ;CPANEL_IN:        in  std_logic_vector(7 downto 0)
         ;LINE_LEFT_NEG:    out std_logic
         ;LINE_LEFT_POS:    out std_logic
         ;LINE_RIGHT_NEG:   out std_logic
         ;LINE_RIGHT_POS:   out std_logic
         )
    ;
end entity;

architecture synthesizer_impl of synthesizer is

    signal clk_even: std_logic := '0';
    signal clk_odd: std_logic := '0';
    signal clk_fast: std_logic := '0';
    signal clk_slow: std_logic := '0';
    signal counter: unsigned(8 downto 0) := (others => '0');
    signal key_code: keys_signal;
    signal key_event: key_event_t;
    signal cpanel_key_code: keys_signal;
    signal cpanel_key_event: key_event_t;

    signal freq: time_signal := (others => '0');
    signal gate: std_logic;
    signal params: synthesis_params;

    signal fifo_in: state_vector_t;
    signal fifo_out: state_vector_t;
    signal z_ampl: voice_signal;
    signal audio_buf: audio_signal;

    signal v_out: std_logic;
begin

    process (CLK)
    begin
        if rising_edge(CLK) then
            if counter = to_unsigned(61, 9) then
                counter <= "000000000";
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_even <= '1' when std_match(counter, "000000---") else '0';
    clk_odd <= '1' when std_match(counter, "000100---") else '0';
    clk_fast <= CLK;
    clk_slow <= '1' when std_match(counter, "1--------") else '0';
        
    cpanel_input_buffer:
        entity
            work.input_buffer (input_buffer_impl)
        port map
            ('1'
            ,clk_even
            ,CPANEL_IN
            ,CPANEL_PROBE
            ,cpanel_key_code
            ,cpanel_key_event
            ,open
            );

    input_buffer:
        entity
            work.input_buffer (input_buffer_impl)
        port map
            ('1'
            ,clk_even
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
            ,clk_odd
            ,params.sp_transform
            ,key_code
            ,key_event
            ,freq
            ,gate
            );

    preset_selector:
        entity
            work.preset_selector (preset_selector_impl)
        port map
            ('1'
            ,clk_odd
            ,cpanel_key_code
            ,cpanel_key_event
            ,params
            );

    circular_buffer:
        entity
            work.circular_buffer (circular_buffer_impl)
        port map
            ('1'
            ,clk_odd
            ,fifo_in
            ,fifo_out
            );

    voice_generator:
        entity
            work.voice_generator (voice_generator_impl)
        port map
            ('1'
            ,clk_even
            ,clk_odd
            ,freq
            ,gate
            ,params
            ,z_ampl
            ,fifo_in
            ,fifo_out
            );

    mixer:
        entity
            work.mixer (mixer_impl)
        port map
            ('1'
            ,clk_odd
            ,z_ampl
            ,audio_buf
            );

	dac:
        entity 
            work.delta_sigma_dac(delta_sigma_dac_impl)
        port map
            ('1'
            ,clk_fast
            ,audio_buf
            ,v_out
            );

    LINE_LEFT_NEG <= v_out;
    LINE_LEFT_POS <= v_out;
    LINE_RIGHT_POS <= '0';
    LINE_RIGHT_NEG <= '0';
end architecture;
