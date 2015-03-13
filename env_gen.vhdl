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

entity env_gen is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;GATE:          in  std_logic
            ;A_RATE:        in  ctl_signal
            ;D_RATE:        in  ctl_signal
            ;S_LVL:         in  ctl_signal
            ;R_RATE:        in  ctl_signal
            ;ENV_IN:        in  time_signal
            ;ENV_OUT:       out time_signal
            ;STAGE_IN:      in  adsr_stage
            ;STAGE_OUT:     out adsr_stage
            ;PREV_GATE_IN:  in  std_logic
            ;PREV_GATE_OUT: out std_logic
            )
    ;
end entity;

architecture env_gen_impl of env_gen is
    constant zero_f : time_signal := (others => '0');
    constant zero_c : ctl_signal := (others => '0');
    constant time_max_val : time_signal := to_unsigned(time_max - 1, time_bits);
    constant bit_diff : natural := time_bits - ctl_bits - 1;
    constant zero_f_min_c : unsigned(bit_diff downto 0) := (others => '0');

    signal env_out_buf: time_signal := (others => '0');
    signal stage_out_buf: adsr_stage := adsr_rel;
    signal prev_gate_out_buf: std_logic := '0';

begin
    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            if PREV_GATE_IN = '0' and GATE = '1' then
                stage_out_buf <= adsr_attack;
                prev_gate_out_buf <= '1';
            elsif PREV_GATE_IN = '1' and GATE = '0' then
                stage_out_buf <= adsr_rel;
                prev_gate_out_buf <= '0';
            end if;

            case STAGE_IN is
                when adsr_attack =>
                    if ENV_IN > time_max_val - A_RATE then
                        env_out_buf <= time_max_val;
                        stage_out_buf <= adsr_decay;
                    else
                        env_out_buf <= ENV_IN + A_RATE;
                    end if;
                when adsr_decay =>
                    if ENV_IN < (S_LVL & zero_f_min_c) + D_RATE then
                        env_out_buf <= S_LVL & zero_f_min_c;
                        stage_out_buf <= adsr_sustain;
                    else
                        env_out_buf <= ENV_IN - D_RATE;
                    end if;
                when adsr_sustain =>
                    null;
                when adsr_rel =>
                    if ENV_IN < R_RATE then
                        env_out_buf <= zero_f;
                    else
                        env_out_buf <= ENV_IN - R_RATE;
                    end if;
                when others => -- non-binary values
                    null;
            end case;
        end if;
    end process;

    ENV_OUT <= env_out_buf;
    STAGE_OUT <= stage_out_buf;
    PREV_GATE_OUT <= prev_gate_out_buf;
end architecture;
