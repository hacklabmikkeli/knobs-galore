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

entity amplifier_test is
end entity;

architecture amplifier_test_impl of amplifier_test is
    signal      CLK:            std_logic := '1';
    signal      CLK_BAR:        std_logic;
    signal      GAIN:           ctl_signal := to_unsigned(0, ctl_bits);
    signal      AUDIO_IN:       voice_signal := to_unsigned(0, ctl_bits);
    signal      AUDIO_OUT:      voice_signal;

begin
    CLK_BAR <= not CLK;

    amplifier : 
        entity work.amplifier(amplifier_impl)
        port map ('1', CLK, CLK_BAR, GAIN, AUDIO_IN, AUDIO_OUT);

    process begin
        for j in 0 to ctl_max - 1 loop
            GAIN <= to_unsigned(j, GAIN'length);
            for i in 0 to ctl_max - 1 loop
                AUDIO_IN <= to_unsigned(i, AUDIO_IN'length);
                wait for 1 ns;
                CLK <= not CLK;
                wait for 1 ns;
                CLK <= not CLK;
                wait for 1 ns;
            end loop;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
