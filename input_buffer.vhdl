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

entity input_buffer is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;KEYS_IN:       in  std_logic_vector(7 downto 0)
            ;KEYS_PROBE:    out std_logic_vector(4 downto 0)
            ;KEY_CODE:      out keys_signal
            ;KEY_EVENT:     out key_event_t
            ;READY:         out std_logic
            );
end entity;

architecture input_buffer_impl of input_buffer is
    signal keys_buf: std_logic_vector(63 downto 0) := (others => '0');
    signal keys_mask: std_logic_vector(7 downto 0) := (others => '0');
    signal probe_clock: unsigned(5 downto 0) := (others => '0');
    signal keys_probe_buf: std_logic_vector(4 downto 0) := (others => 'Z');
    signal key_code_buf: keys_signal := (others => '0');
    signal key_event_buf: key_event_t := (others => '0');
    signal key_code_translated: keys_signal;
    signal counter: unsigned(7 downto 0);

begin


    process(CLK)
        variable old_key_state: std_logic;
        variable new_key_state: std_logic;
    begin
        if EN = '1' and rising_edge(CLK) then
            if counter = "00000000" then
                case probe_clock(2 downto 0) is
                    when "000"=>
                        keys_mask <= "10000000";
                    when "001"=>
                        keys_mask <= "01000000";
                    when "010"=>
                        keys_mask <= "00100000";
                    when "011"=>
                        keys_mask <= "00010000";
                    when "100"=>
                        keys_mask <= "00001000";
                    when "101"=>
                        keys_mask <= "00000100";
                    when "110"=>
                        keys_mask <= "00000010";
                    when "111"=>
                        keys_mask <= "00000001";
                    when others =>
                        null;
                end case;

                case probe_clock(5 downto 3) is
                    when "000" =>
                        keys_probe_buf <= "1ZZZZ";
                    when "001" =>
                        keys_probe_buf <= "Z1ZZZ";
                    when "010" =>
                        keys_probe_buf <= "ZZ1ZZ";
                    when "011" =>
                        keys_probe_buf <= "ZZZ1Z";
                    when "100" =>
                        keys_probe_buf <= "ZZZZ1";
                    when others =>
                        keys_probe_buf <= "ZZZZZ";
                end case;

                key_event_buf <= key_event_idle;
            elsif counter = "10000000" then
                old_key_state := keys_buf(to_integer(probe_clock));

                if (KEYS_IN and keys_mask) /= "00000000" then
                    new_key_state := '1';
                else
                    new_key_state := '0';
                end if;

                if old_key_state = '0' and new_key_state = '1' then
                    key_event_buf <= key_event_make;
                elsif old_key_state = '1' and new_key_state = '0' then
                    key_event_buf <= key_event_break;
                else
                    key_event_buf <= key_event_idle;
                end if;

                keys_buf(to_integer(probe_clock)) <= new_key_state;
                key_code_buf <= probe_clock;
                if probe_clock = "100100" then
                    probe_clock <= "000000";
                else
                    probe_clock <= probe_clock + 1;
                end if;
            elsif counter = "10000001" then
                key_event_buf <= key_event_idle;
            elsif counter = "10001000" then
                keys_probe_buf <= "00000";
            end if;

            counter <= counter + 1;
        end if;
    end process;

    KEY_CODE <= key_code_buf;
    KEY_EVENT <= key_event_buf;
    KEYS_PROBE <= keys_probe_buf;
    READY <= '1';
end architecture;
