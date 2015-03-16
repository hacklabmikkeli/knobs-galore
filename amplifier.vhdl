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
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;GAIN:          in  ctl_signal
            ;AUDIO_IN:      in  ctl_signal
            ;AUDIO_OUT:     out ctl_signal
            )
    ;
end entity;

architecture amplifier_impl of amplifier is
    function transfer(gain : integer
                     ;x : integer
                     )
    return integer is
        constant bias: integer := ctl_max / 2;
    begin
        return ((x - bias) * gain) / ctl_max + bias;
    end function;


    function make_lut return ctl_lut_t is
        variable result : ctl_lut_t;
    begin
        for j in ctl_lut_t'low(1) to ctl_lut_t'high(1) loop
            for i in ctl_lut_t'low(2) to ctl_lut_t'high(2) loop
                result(j,i) := to_unsigned(transfer(i * 16, j),ctl_bits);
            end loop;
        end loop;
        return result;
    end function;

    constant lut : ctl_lut_t := make_lut;
begin
    lookup:
        entity
            work.lookup(lookup_impl)
        generic map
            (lut)
        port map
            (EN
            ,CLK
            ,AUDIO_IN
            ,GAIN
            ,AUDIO_OUT
            );
end architecture;
