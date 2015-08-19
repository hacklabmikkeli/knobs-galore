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
    type step is
    record
        step_key: keys_signal;
        step_event: key_event_t;
        step_duration: natural;
    end record;

    type step_table is array(integer range <>) of step;

    constant steps: step_table(0 to 4) :=
        (("000000", key_event_idle, 524288)
        ,("000001", key_event_make, 1)
        ,("000001", key_event_idle, 524288) -- 1s
        ,("000001", key_event_break, 1)
        ,("000001", key_event_idle, 524288)
        );


    signal CLK:              std_logic := '1';
    signal KEY_CODE:         keys_signal;
    signal KEY_EVENT:        key_event_t;
    signal AUDIO:            audio_signal;

begin

    synthesizer_sim : entity work.synthesizer_sim(synthesizer_sim_impl)
                    port map (CLK, KEY_CODE, KEY_EVENT, AUDIO);

    process
        file out_file: text is out "synthesizer_sim_test.out";
        variable out_line: line;
    begin
        for j in steps'range loop
            KEY_CODE <= steps(j).step_key;
            KEY_EVENT <= steps(j).step_event;
            for k in 0 to steps(j).step_duration loop
                CLK <= not CLK;
                wait for 0.8 us;
                CLK <= not CLK;
                wait for 0.8 us;
                write(out_line, to_integer(AUDIO(10 downto 8)));
                writeline(out_file, out_line);
                write(out_line, to_integer(AUDIO(7 downto 0)));
                writeline(out_file, out_line);
            end loop;
        end loop;
        report "end of test" severity note;
        wait;
    end process;
end architecture;
