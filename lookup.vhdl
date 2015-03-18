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

    signal s1_left_ref: ctl_signal := (others => '0');
    signal s1_right_ref: ctl_signal := (others => '0');
    signal s1_y: ctl_signal := (others => '0');

    signal s2_left_mult: unsigned(12 downto 0) := (others => '0');
    signal s2_right_mult: unsigned(12 downto 0) := (others => '0');

    signal s3_z_buf: ctl_signal := (others => '0');

begin
    process(CLK)
        variable x_ix: integer range 0 to 255;
        variable y_ix: integer range 0 to 15;
    begin
        if EN = '1' and rising_edge(CLK) then
            x_ix := to_integer(X);
            y_ix := to_integer(Y(7 downto 4));
            s1_left_ref <= rom(x_ix, y_ix);
        end if;
    end process;

    process(CLK)
        variable y_plusone: unsigned(4 downto 0);
        variable x_ix: integer range 0 to 255;
        variable y_ix: integer range 1 to 16;
    begin
        if EN = '1' and rising_edge(CLK) then
            y_plusone := ("0" & Y(7 downto 4)) + 1;
            x_ix := to_integer(X);
            y_ix := to_integer(y_plusone);
            s1_right_ref <= rom(x_ix, y_ix);
        end if;
    end process;

    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            s1_y <= Y;
        end if;
    end process;

    process(CLK)
        variable s1_y_recip: unsigned(4 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            s1_y_recip := "10000" - s1_y(3 downto 0);
            s2_left_mult <= s1_y_recip * s1_left_ref;
        end if;
    end process;

    process(CLK)
        variable s1_y_fact: unsigned(4 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            s1_y_fact := "0" & s1_y(3 downto 0);
            s2_right_mult <= s1_y_fact * s1_right_ref;
        end if;
    end process;

    process(CLK)
        variable s2_z_wide: unsigned(12 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            s2_z_wide := s2_left_mult + s2_right_mult;
            s3_z_buf <= s2_z_wide(11 downto 4);
        end if;
    end process;

    Z <= s3_z_buf;

end architecture;
