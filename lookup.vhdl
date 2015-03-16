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

entity lookup is
    generic (TABLE:         ctl_lut_t
            );
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;X:             in  ctl_signal
            ;Y:             in  ctl_signal
            ;Z:             out ctl_signal
            );
end entity;

architecture lookup_impl of lookup is
    attribute ram_style: string;
    signal rom: ctl_lut_t := TABLE;
    attribute ram_style of rom: signal is "block";
    signal left_ref: ctl_signal := (others => '0');
    signal right_ref: ctl_signal := (others => '0');
    signal left_mult: unsigned(12 downto 0) := (others => '0');
    signal right_mult: unsigned(12 downto 0) := (others => '0');
    signal z_buf: ctl_signal := (others => '0');

begin
    process(CLK)
        variable x_ix: integer range 0 to 255;
        variable y_ix: integer range 0 to 15;
    begin
        if EN = '1' and rising_edge(CLK) then
            x_ix := to_integer(X);
            y_ix := to_integer(Y(7 downto 4));
            left_ref <= rom(x_ix, y_ix);
        end if;
    end process;

    process(CLK)
        variable y_plusone: unsigned(3 downto 0);
        variable x_ix: integer range 0 to 255;
        variable y_ix: integer range 0 to 15;
    begin
        if EN = '1' and rising_edge(CLK) then
            if Y(7 downto 4) = "1111" then
                y_plusone := "1111";
            else 
                y_plusone := Y(7 downto 4) + 1;
            end if;
            x_ix := to_integer(X);
            y_ix := to_integer(y_plusone);
            right_ref <= rom(x_ix, y_ix);
        end if;
    end process;

    process(CLK)
        variable y_recip: unsigned(4 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            y_recip := "10000" - ("0" & Y(3 downto 0));
            left_mult <= y_recip * left_ref;
        end if;
    end process;

    process(CLK)
        variable y_fact: unsigned(4 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            y_fact := "0" & Y(3 downto 0);
            right_mult <= y_fact * right_ref;
        end if;
    end process;

    process(CLK)
        variable z_wide: unsigned(12 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            z_wide := left_mult + right_mult;
            z_buf <= z_wide(11 downto 4);
        end if;
    end process;

    Z <= z_buf;

end architecture;
