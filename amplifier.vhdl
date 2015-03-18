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
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.common.all;

entity amplifier is
    -- delay 2
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;GAIN:          in  ctl_signal
            ;AUDIO_IN:      in  ctl_signal
            ;AUDIO_OUT:     out ctl_signal
            )
    ;
end entity;

architecture amplifier_impl of amplifier is
    -- AUDIO_OUT = 
    --    (GAIN * AUDIO_IN)         / CTL_MAX + 
    --    ((CTL_MAX - GAIN) * BIAS) / CTL_MAX
    constant bias: ctl_signal := ('1', others => '0');

    signal GX_N: ctl_signal := (others => '0');
    signal N_Gb_N: ctl_signal := (others => '0');
    signal audio_out_buf: ctl_signal := (others => '0');
begin
    process (CLK)
        constant ctl_max_cs: ctl_signal := (others => '1');

        variable GX: unsigned(ctl_bits * 2 - 1 downto 0);
        variable N_Gb: unsigned(ctl_bits * 2 - 1 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            -- stage 1
            GX := GAIN * AUDIO_IN;
            GX_N <= GX(ctl_bits * 2 - 1 downto ctl_bits);
            N_Gb := (not GAIN) * bias;
            N_Gb_N <= N_Gb(ctl_bits * 2 - 1 downto ctl_bits);

            -- stage 2
            audio_out_buf <= GX_N + N_Gb_N;
        end if;
    end process;

    AUDIO_OUT <= audio_out_buf;
end architecture;
