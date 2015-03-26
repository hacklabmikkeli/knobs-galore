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
        step_freq: natural;
        step_gate: std_logic;
        step_duration: natural;
        step_params: synthesis_params;
    end record;

    type step_table is array(integer range <>) of step;

    constant steps: step_table(0 to 115) :=
        ((55, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(55, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(69, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(138, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(277, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(220, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 1000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '1', 7000, (mode_saw_res, x"00", x"E0", x"A0", x"40", x"00", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(110, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"10", x"FF", x"01", x"FE", x"10"))
        ,(330, '1', 128000, (mode_saw_fat, x"00", x"A0", x"01", x"02", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(330, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(220, '1', 128000, (mode_saw_fat, x"00", x"A0", x"01", x"02", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(220, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(294, '1', 128000, (mode_saw_fat, x"00", x"A0", x"01", x"02", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(294, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(165, '1', 128000, (mode_saw_fat, x"00", x"A0", x"01", x"02", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(165, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(220, '1', 144000, (mode_saw_fat, x"00", x"A0", x"01", x"02", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(220, '0', 36000, (mode_saw_fat, x"00", x"A0", x"A0", x"40", x"A0", x"03", x"FF", x"01", x"FE", x"04"))
        ,(440, '1', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '1', 48000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '0', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '1', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '0', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '1', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '0', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '1', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '0', 18000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '1', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(440, '0', 36000, (mode_mix, x"00", x"A0", x"A0", x"06", x"20", x"FF", x"FF", x"01", x"FE", x"FF"))
        ,(330, '1', 96000, (mode_saw_res, x"00", x"A0", x"02", x"01", x"00", x"10", x"FF", x"01", x"FE", x"07"))
        ,(330, '0', 36000, (mode_saw_res, x"00", x"A0", x"A0", x"40", x"00", x"10", x"FF", x"01", x"FE", x"07"))
        ,(220, '1', 128000, (mode_saw_res, x"00", x"A0", x"02", x"01", x"00", x"10", x"FF", x"01", x"FE", x"07"))
        ,(220, '0', 36000, (mode_saw_res, x"00", x"A0", x"A0", x"40", x"00", x"10", x"FF", x"01", x"FE", x"07"))
        );


    signal CLK:              std_logic := '1';
    signal FREQ:             time_signal;
    signal GATE:             std_logic;
    signal PARAM:            synthesis_params;
    signal AUDIO:            ctl_signal;

begin

    synthesizer_sim : entity work.synthesizer_sim(synthesizer_sim_impl)
                    port map (CLK, FREQ, GATE, PARAM, AUDIO);

    process
        file out_file: text is out "synthesizer_sim_test.out";
        variable out_line: line;
    begin
        for j in steps'range loop
            FREQ <= to_unsigned(steps(j).step_freq, time_bits);
            GATE <= steps(j).step_gate;
            PARAM <= steps(j).step_params;
            for k in 0 to steps(j).step_duration loop
                CLK <= not CLK;
                wait for 7 us;
                CLK <= not CLK;
                wait for 7 us;
                write(out_line, to_integer(AUDIO));
                writeline(out_file, out_line);
            end loop;
        end loop;
        report "end of test" severity note;
        wait;
    end process;
end architecture;
