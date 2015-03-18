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

entity phase_distort is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;WAVEFORM:      in  waveform_t
            ;CUTOFF:        in  ctl_signal
            ;THETA_IN:      in  ctl_signal
            ;THETA_OUT:     out ctl_signal
            ;GAIN_IN:       in  ctl_signal
            ;GAIN_THRU:     out ctl_signal
            )
    ;
end entity;

architecture phase_distort_impl of phase_distort is
    function transfer_saw
        (cutoff: integer
        ;x: integer
        )
    return integer is
        variable y0 : integer;
        variable y : integer;
        variable k : integer;

    begin
        k := (ctl_max - cutoff) / 2;
        y0 := (ctl_max / 2) - k;
        if x < k then
            y := (x * y0) / k;
        else
            y := y0 - ((x-k) * y0) / (ctl_max - k);
        end if;
        y := y + x;
        if y > ctl_max - 1 then
            return ctl_max - 1;
        else
            return y;
        end if;
    end function;

    function transfer_sq
        (cutoff: integer
        ;x: integer
        )
    return integer is
        variable k : integer;
        variable y0 : integer;
        variable y : integer;

    begin
        k := (ctl_max - cutoff) / 4;
        y0 := ctl_max / 4;
        if x < k then
            y := (x * y0) / k;
        elsif x < (ctl_max / 2) - k then
            y := y0;
        elsif x < (ctl_max / 2) + k then
            y := y0 + (x + k - (ctl_max / 2)) * y0 / k;
        elsif x < ctl_max - k then
            y := (ctl_max / 2) + y0;
        else
            y := (ctl_max / 2) + y0 + (x + k - ctl_max) * y0 / k;
        end if;
        if y > ctl_max - 1 then
            return ctl_max - 1;
        else
            return y;
        end if;
    end function;

    function make_lut_saw return ctl_lut_t is
        variable result : ctl_lut_t;
    begin
        for j in ctl_lut_t'low(1) to ctl_lut_t'high(1) loop
            for i in ctl_lut_t'low(2) to ctl_lut_t'high(2) loop
                result(j,i) := to_unsigned(transfer_saw(i*16, j),ctl_bits);
            end loop;
        end loop;
        return result;
    end function;

    function make_lut_sq return ctl_lut_t is
        variable result : ctl_lut_t;
    begin
        for j in ctl_lut_t'low(1) to ctl_lut_t'high(1) loop
            for i in ctl_lut_t'low(2) to ctl_lut_t'high(2) loop
                result(j,i) := to_unsigned(transfer_sq(i*16, j),ctl_bits);
            end loop;
        end loop;
        return result;
    end function;

    constant lut_saw: ctl_lut_t := make_lut_saw;
    constant lut_sq: ctl_lut_t := make_lut_sq;
    constant zero: ctl_signal := (others => '0');

    signal s1_waveform: waveform_t := waveform_saw;
    signal s1_theta_saw: ctl_signal;
    signal s1_theta_sq: ctl_signal;
    signal s1_gain: ctl_signal := (others => '0');

    signal s2_theta_out_buf: ctl_signal := (others => '0');
    signal s2_gain_pass_buf: ctl_signal := (others => '0');
begin

    lookup_saw:
        entity
            work.lookup(lookup_impl)
        generic map
            (lut_saw)
        port map
            (EN
            ,CLK
            ,THETA_IN
            ,CUTOFF
            ,s1_theta_saw
            );

    lookup_sq:
        entity
            work.lookup(lookup_impl)
        generic map
            (lut_sq)
        port map
            (EN
            ,CLK
            ,THETA_IN
            ,CUTOFF
            ,s1_theta_sq
            );
    
    process (CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            s1_waveform <= WAVEFORM;
            s1_gain <= GAIN_IN;
        end if;
    end process;

    process (CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            case s1_waveform is
                when waveform_saw =>
                    s2_theta_out_buf <= s1_theta_saw;
                when waveform_sq =>
                    s2_theta_out_buf <= s1_theta_sq;
                when others =>
                    s2_theta_out_buf <= (others => '0');
            end case;

            s2_gain_pass_buf <= s1_gain;
        end if;
    end process;

    THETA_OUT <= s2_theta_out_buf;
    GAIN_THRU <= s2_gain_pass_buf;
end architecture;
