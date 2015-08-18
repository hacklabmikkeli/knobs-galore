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
use work.common.all;

entity mixer is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;MUXED_IN:      in  ctl_signal
            ;AUDIO_OUT:     out audio_signal
            );
end entity;

architecture mixer_impl of mixer is
    signal accumulator: audio_signal := (others => '0');
    signal audio_out_buf: audio_signal := (others => '0');
    signal counter: unsigned(voices_bits - 1 downto 0) := (others=>'0');

begin
    process(CLK)
        variable zero: unsigned(voices_bits - 1 downto 0) := (others=>'0');
    begin
        if EN = '1' and rising_edge(CLK) then
            if counter = zero then
                audio_out_buf <= accumulator;
                accumulator(ctl_bits - 1 downto 0) <= MUXED_IN;
                accumulator(audio_bits - 1 downto ctl_bits) <= (others=>'0');
            else
                accumulator <= accumulator + MUXED_IN;
            end if;

            counter <= counter + 1;
        end if;
    end process;

    AUDIO_OUT <= audio_out_buf;
end architecture;
