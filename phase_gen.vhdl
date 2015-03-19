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

entity phase_gen is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;FREQ:          in  time_signal
            ;PHASE_IN:      in  time_signal
            ;PHASE_OUT:     out time_signal
            ;WAVE_SEL_IN:   in  std_logic
            ;WAVE_SEL_OUT:  out std_logic
            )
    ;
end entity;

architecture phase_gen_impl of phase_gen is
    signal s1_phase_out_buf: time_signal := (others => '0');
    signal s1_wave_sel_out_buf: std_logic := '0';

begin
    process(CLK)
        variable combined: unsigned(time_bits downto 0) := (others => '0');
    begin
        if EN = '1' and rising_edge(CLK) then
            combined(time_bits) := WAVE_SEL_IN;
            combined(time_bits - 1 downto 0) := PHASE_IN;
            combined := combined + FREQ;
            s1_wave_sel_out_buf <= combined(time_bits);
            s1_phase_out_buf <= combined(time_bits - 1 downto 0);
        end if;
    end process;

    PHASE_OUT <= s1_phase_out_buf;
    WAVE_SEL_OUT <= s1_wave_sel_out_buf;

end architecture;
