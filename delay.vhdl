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

entity delay is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;DATA_IN:       in  ctl_signal
            ;DATA_OUT:      out ctl_signal
            );
end entity;

architecture delay_impl of delay is
    type data_buffer is array (0 to 2) of ctl_signal;

    signal data: data_buffer := (others => (others => '0'));

begin
    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            data(0 to 1) <= data(1 to 2);
            data(2) <= DATA_IN;
        end if;
    end process;

    DATA_OUT <= data(0);
end architecture;
