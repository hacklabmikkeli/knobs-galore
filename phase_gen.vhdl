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
            ;FREQ1:         in  time_signal
            ;FREQ2:         in  time_signal
            ;PHASE1_IN:     in  time_signal
            ;PHASE2_IN:     in  time_signal
            ;WAVE_SEL_IN:   in  std_logic
            ;PHASE1_OUT:    out time_signal
            ;PHASE2_OUT:    out time_signal
            ;WAVE_SEL_OUT:  out std_logic
            )
    ;
end entity;

architecture phase_gen_impl of phase_gen is
    signal phase1_out_buf: time_signal := (others => '0');
    signal phase2_out_buf: time_signal := (others => '0');
    signal wave_sel_out_buf: std_logic := '0';

begin
    process(CLK)
        variable overflow_check: unsigned(time_bits downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            overflow_check := ('0' & PHASE1_IN) + ('0' & FREQ1);

            if overflow_check(overflow_check'high) = '1' then
                wave_sel_out_buf <= not WAVE_SEL_IN;
                phase1_out_buf <= (others => '0');
                phase2_out_buf <= (others => '0');
            else
                wave_sel_out_buf <= WAVE_SEL_IN;
                phase1_out_buf <= PHASE1_IN + FREQ1;
                phase2_out_buf <= PHASE2_IN + FREQ2;
            end if;
        end if;
    end process;

    PHASE1_OUT <= phase1_out_buf;
    PHASE2_OUT <= phase2_out_buf;
    WAVE_SEL_OUT <= wave_sel_out_buf;

end architecture;
