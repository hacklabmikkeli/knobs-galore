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

entity input_buffer_test is
end entity;

architecture input_buffer_test_impl of input_buffer_test is
    signal   CLK:           std_logic := '1';
    signal   KEYS_IN:       std_logic_vector(4 downto 0) := (others => '1');
    signal   KEYS_PROBE:    std_logic_vector(7 downto 0) := (others => 'Z');
    signal   KEY_CODE:      std_logic_vector(5 downto 0) :=  (others => '0');
    signal   KEY_EVENT:     key_event_t;
    constant length:        integer := 100000;

begin
    input_buffer : entity
                    work.input_buffer(input_buffer_impl)
                port map
                    ('1'
                    ,CLK
                    ,KEYS_IN
                    ,KEYS_PROBE
                    ,KEY_CODE
                    ,KEY_EVENT
                    ,open
                    );

    process begin
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
