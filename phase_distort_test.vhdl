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

entity phase_distort_test is
end entity;

architecture phase_distort_test_impl of phase_distort_test is
    signal      CLK:            std_logic := '1';
    signal      CUTOFF:         ctl_signal := (others => '0');
    signal      THETA_IN:       ctl_signal := (others => '0');
    signal      SAW_THETA:      ctl_signal;
    signal      SQR_THETA:      ctl_signal;

begin
    phase_distort_saw : 
        entity work.phase_distort(phase_distort_impl)
        port map ('1', CLK, waveform_saw, '0', CUTOFF, THETA_IN, SAW_THETA);

    phase_distort_sq : 
        entity work.phase_distort(phase_distort_impl)
        port map ('1', CLK, waveform_sq, '0', CUTOFF, THETA_IN, SQR_THETA);

    process begin
        for j in 0 to ctl_max - 1 loop
            CUTOFF <= to_unsigned(j, CUTOFF'length);
            for i in 0 to ctl_max - 1 loop
                THETA_IN <= to_unsigned(i, THETA_IN'length);
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
