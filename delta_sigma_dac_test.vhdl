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

entity delta_sigma_dac_test is
end entity;

architecture delta_sigma_dac_test_impl of delta_sigma_dac_test is
    signal  THETA:  ctl_signal := (others => '0');
    signal  Zctl:   voice_signal := (others => '0');
    signal  Z:      audio_signal := (others => '0');
    signal  CLK:    std_logic := '1';
    signal  Vout:   std_logic;
    constant count: natural := 30;
begin
    waveshaper_sin : entity work.waveshaper(waveshaper_sin)
                     port map ('1', CLK, THETA, Zctl, (others => '0'), open);

    delta_sigma_dac : entity work.delta_sigma_dac(delta_sigma_dac_impl)
                     port map ('1', CLK, Z, Vout); 

    process begin
        for k in 0 to ctl_max - 1 loop
            THETA <= to_unsigned(k, ctl_bits);
            for i in 1 to count loop
                CLK <= not CLK;
                wait for 1 ns;
            end loop;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;

    Z <= (others => '0');
end architecture;
