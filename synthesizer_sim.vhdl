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
         ;KEY_CODE:         in  keys_signal
         ;KEY_EVENT:        in  key_event_t
         ;AUDIO:            out audio_signal
         )
    ;
end entity;

architecture synthesizer_sim_impl of synthesizer_sim is
    signal clk_even: std_logic := '0';
    signal clk_odd: std_logic := '0';
    signal clk_slow: std_logic := '0';
    signal clk_divider: unsigned(4 downto 0) := (others => '0');

    signal freq: time_signal := (others => '0');
    signal gate: std_logic;

    signal fifo_in: state_vector_t;
    signal fifo_out: state_vector_t;
    signal z_ampl: ctl_signal;
    signal audio_buf: audio_signal;
    signal audio_buf_del: audio_signal;

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            clk_divider <= clk_divider + 1;
        end if;
    end process;
    
    clk_even <= '1' when std_match(clk_divider, "0000-") else '0';
    clk_odd <= '1' when std_match(clk_divider, "0001-") else '0';
    clk_slow <= '1' when std_match(clk_divider, "1----") else '0';

    voice_allocator:
        entity
            work.voice_allocator (voice_allocator_impl)
        port map
            ('1'
            ,clk_odd
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
            ,(mode_saw_fat
             ,x"00", x"A0", x"01", x"01", x"00", x"01"
             ,x"FF", x"01", x"FF", x"01"
             )
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

    delay:
        entity
            work.audio_delay (audio_delay_impl)
        port map
            ('1'
            ,clk_slow
            ,audio_buf
            ,audio_buf_del
            );

    AUDIO <= audio_buf 
             + ('0' & audio_buf_del(audio_signal'high - 1 downto
                        audio_signal'low));
end architecture;
