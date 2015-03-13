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

entity delta_sigma_dac is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;Zin:           in  audio_signal
            ;Vout:          out std_logic
            )
    ;
end entity;

architecture delta_sigma_dac_impl of delta_sigma_dac is
    subtype sigma_t is signed(audio_signal'high + 1 downto 0);

    signal sigma : sigma_t := (others => '0');
begin
    process (CLK)
        variable delta : sigma_t;
        variable zin_s : sigma_t;
    begin
        if EN = '1' and rising_edge(CLK) then
            zin_s := signed("0" & Zin);
            delta := ('0', others => not sigma(sigma'left));
            sigma <= (sigma + zin_s) - delta;
        end if;
    end process;

    Vout <= not sigma(sigma'left);
end architecture;
