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

entity voice_controller is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;MODE:          in  mode_t
            ;FREQ:          in  time_signal
            ;CUTOFF_IN:     in  time_signal
            ;CUTOFF_OUT:    out ctl_signal
            ;GAIN_IN:       in  time_signal
            ;GAIN_OUT:      out ctl_signal
            ;THETA_REF:     in  time_signal
            ;THETA_OUT:     out ctl_signal
            ;WAVEFORM:      out waveform_t
            )
    ;
end entity;

architecture voice_controller_impl of voice_controller is
    type lut_t is array(0 to ctl_hi) of unsigned(ctl_bits + 3 downto 0);

    function make_cutoff_to_fact
    return lut_t is
        variable zero: unsigned(ctl_bits + 3 downto 0) := (others => '0');
        variable retval: lut_t := (others => (others => '0'));
    begin
        for i in 0 to 254 loop
            retval(i) := to_unsigned(4096 / (256 - i), ctl_bits + 4);
        end loop;
        retval(255) := not zero;
        return retval;
    end function;

    constant cutoff_to_fact: lut_t := make_cutoff_to_fact;

    signal s1_theta_osc1: ctl_signal := (others => '0');
    signal s1_theta_osc2_fat: ctl_signal := (others => '0');
    signal s1_theta_osc2_res: ctl_signal := (others => '0');
    signal s1_cutoff: ctl_signal := (others => '0');
    signal s1_gain: ctl_signal := (others => '0');
    signal s1_gain_windowed: ctl_signal := (others => '0');
    signal s1_wave_sel: std_logic := '0';
    signal s1_mode: mode_t := mode_saw;
    signal s2_waveform_buf: waveform_t := waveform_saw;
    signal s2_cutoff_out_buf: ctl_signal := (others => '0');
    signal s2_theta_out_buf: ctl_signal := (others => '0');
    signal s2_gain_out_buf: ctl_signal := (others => '0');
begin

    process (CLK)
        variable cutoff: ctl_signal;
        variable theta_osc1: ctl_signal;
        variable theta_osc1_wide: unsigned(time_bits * 2 - 1 downto 0);
        variable fact_osc2_fat: ctl_signal := ('1', others => '0');
        variable fact_osc2_res: unsigned(ctl_bits + 3 downto 0);
        variable theta_osc2_fat_wide: unsigned(ctl_bits * 2 - 1 downto 0);
        variable theta_osc2_fat: ctl_signal;
        variable theta_osc2_res_wide: unsigned(ctl_bits * 2 + 3 downto 0);
        variable theta_osc2_res: ctl_signal;
        variable gain_windowed_wide: unsigned(ctl_bits * 2 - 1 downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            cutoff := to_ctl(CUTOFF_IN);
            theta_osc1_wide := THETA_REF * FREQ;
            theta_osc1 := theta_osc1_wide(time_bits - 2 
                                          downto time_bits - ctl_bits - 1);
            if THETA_REF(time_bits-2) = '1' then
                fact_osc2_fat(6 downto 0) 
                    := THETA_REF(time_bits-2 downto time_bits-8);
            else
                fact_osc2_fat(6 downto 0) 
                    := not THETA_REF(time_bits-2 downto time_bits-8);
            end if;
            theta_osc2_fat_wide := fact_osc2_fat * theta_osc1;
            theta_osc2_fat := theta_osc2_fat_wide(time_bits-3 
                                                  downto time_bits-ctl_bits-2);
            fact_osc2_res := cutoff_to_fact(to_integer(cutoff));
            theta_osc2_res_wide := fact_osc2_res * theta_osc1;
            theta_osc2_res := theta_osc2_res_wide(ctl_bits + 3 downto 4);
            gain_windowed_wide := to_ctl(GAIN_IN) * not theta_osc1;

            s1_theta_osc1 <= theta_osc1;
            s1_theta_osc2_fat <= theta_osc2_fat;
            s1_theta_osc2_res <= theta_osc2_res;
            s1_cutoff <= cutoff;
            s1_gain <= to_ctl(GAIN_IN);
            s1_gain_windowed <= gain_windowed_wide(ctl_bits * 2 - 1
                                                   downto ctl_bits);
            s1_wave_sel <= theta_osc1_wide(time_bits - 1);
            s1_mode <= MODE;

            case s1_mode is
                when   mode_saw
                     | mode_saw_fat
                     | mode_saw_res
                     | mode_saw_sync =>
                    s2_waveform_buf <= waveform_saw;
                when   mode_sq
                     | mode_sq_fat
                     | mode_sq_res =>
                    s2_waveform_buf <= waveform_sq;
                when   mode_mix =>
                    if s1_wave_sel = '0' then
                        s2_waveform_buf <= waveform_saw;
                    else
                        s2_waveform_buf <= waveform_sq;
                    end if;
                when others =>
                    null;
            end case;

            case s1_mode is
                when   mode_saw
                     | mode_saw_fat
                     | mode_sq
                     | mode_sq_fat
                     | mode_saw_sync
                     | mode_mix =>
                    s2_cutoff_out_buf <= s1_cutoff;
                when   mode_saw_res
                     | mode_sq_res =>
                    if s1_wave_sel = '0' then
                        s2_cutoff_out_buf <= s1_cutoff;
                    else
                        s2_cutoff_out_buf <= (others => '0');
                    end if;
                when others =>
                    null;
            end case;

            case s1_mode is
                when   mode_saw
                     | mode_sq
                     | mode_mix =>
                    s2_theta_out_buf <= s1_theta_osc1;
                when   mode_saw_fat
                     | mode_sq_fat =>
                    if s1_wave_sel = '0' then
                        s2_theta_out_buf <= s1_theta_osc1;
                    else
                        s2_theta_out_buf <= s1_theta_osc2_fat;
                    end if;
                when   mode_saw_res
                     | mode_sq_res =>
                    if s1_wave_sel = '0' then
                        s2_theta_out_buf <= s1_theta_osc1;
                    else
                        s2_theta_out_buf <= s1_theta_osc2_res;
                    end if;
                when others =>
                    null;
            end case;

            case s1_mode is
                when   mode_saw
                     | mode_sq
                     | mode_mix =>
                    s2_gain_out_buf <= s1_gain;
                when   mode_saw_fat
                     | mode_sq_fat
                     | mode_saw_res
                     | mode_sq_res
                     | mode_saw_sync =>
                    if s1_wave_sel = '0' then
                        s2_gain_out_buf <= s1_gain;
                    else
                        s2_gain_out_buf <= s1_gain_windowed;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;

    WAVEFORM <= s2_waveform_buf;
    CUTOFF_OUT <= s2_cutoff_out_buf;
    THETA_OUT <= s2_theta_out_buf;
    GAIN_OUT <= s2_gain_out_buf;

end architecture;
