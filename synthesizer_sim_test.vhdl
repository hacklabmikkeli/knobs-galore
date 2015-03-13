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
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use work.common.all;

entity synthesizer_sim_test is
end entity;

architecture synthesizer_sim_test_impl of synthesizer_sim_test is
    type key_combination_table is array(integer range <>) of std_logic_vector(7 downto 0);

    constant key_combinations : key_combination_table(15 downto 0) :=
        ("00000000"
        ,"10000000"
        ,"00000000"
        ,"01000000"
        ,"00000000"
        ,"00100000"
        ,"00000000"
        ,"00010000"
        ,"00000000"
        ,"00001000"
        ,"00000000"
        ,"00000100"
        ,"00000000"
        ,"00000010"
        ,"00000000"
        ,"00000001"
        );

    signal CLK:              std_logic := '1';
    signal KEYS:             std_logic_vector(7 downto 0) := key_combinations(0);
    signal AUDIO:            ctl_signal;

begin

    synthesizer_sim : entity work.synthesizer_sim(synthesizer_sim_impl)
                    port map (CLK, KEYS, AUDIO);

    process
        file out_file: text is out "synthesizer_sim_test.out";
        variable out_line: line;
    begin
        for j in key_combinations'range loop
            KEYS <= key_combinations(j);
            for k in 0 to 65535 loop
                CLK <= not CLK;
                wait for 31.25 ns;
                CLK <= not CLK;
                wait for 31.25 ns;
                write(out_line, to_integer(AUDIO));
                writeline(out_file, out_line);
            end loop;
        end loop;
        report "end of test" severity note;
        wait;
    end process;
end architecture;
