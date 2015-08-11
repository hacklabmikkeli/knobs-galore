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
            ;KEYS_IN:       in  std_logic_vector(4 downto 0)
            ;KEYS_PROBE:    out std_logic_vector(7 downto 0)
            ;KEY_CODE:      out std_logic_vector(5 downto 0)
            ;KEY_EVENT:     out key_event_t
            ;READY:         out std_logic
            );
end entity;

architecture input_buffer_impl of input_buffer is
    signal keys_buf: std_logic_vector(63 downto 0) := (others => '0');
    signal probe_clock: unsigned(5 downto 0) := (others => '0');
    signal key_code_buf: std_logic_vector(5 downto 0);
    signal key_event_buf: key_event_t;
    signal is_probing: std_logic := '1';

begin

    with probe_clock(2 downto 0) select KEYS_PROBE <=
        "1ZZZZZZZ" when "000",
        "Z1ZZZZZZ" when "001",
        "ZZ1ZZZZZ" when "010",
        "ZZZ1ZZZZ" when "011",
        "ZZZZ1ZZZ" when "100",
        "ZZZZZ1ZZ" when "101",
        "ZZZZZZ1Z" when "110",
        "ZZZZZZZ1" when "111",
        "ZZZZZZZZ" when others;

    process(CLK)
        variable new_val: std_logic := '0';
        variable old_val: std_logic := '0';
        variable keys_in_padded: std_logic_vector(7 downto 0) 
                                                            := (others => '0');
    begin
        if EN = '1' and rising_edge(CLK) then
            if is_probing = '1' then

                probe_clock <= probe_clock + "000001";

                is_probing <= '0';
            else

                keys_in_padded(4 downto 0) := KEYS_IN;
                old_val := keys_buf(to_integer(probe_clock));
                new_val := keys_in_padded(to_integer(probe_clock(5 downto 3)));

                if old_val = '0' and new_val = '1' then
                    key_event_buf <= key_event_make;
                elsif old_val = '1' and new_val = '0' then
                    key_event_buf <= key_event_break;
                else
                    key_event_buf <= key_event_idle;
                end if;

                key_code_buf <= std_logic_vector(probe_clock);
                keys_buf(to_integer(probe_clock)) <= new_val;

                is_probing <= '1';
            end if;
        end if;
    end process;

    KEY_CODE <= key_code_buf;
    KEY_EVENT <= key_event_buf;
    READY <= is_probing;
end architecture;
