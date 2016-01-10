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

entity voice_allocator is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;OCTAVER:       in  std_logic
            ;KEY_CODE:      in  keys_signal
            ;KEY_EVENT:     in  key_event_t
            ;FREQ:          out time_signal
            ;GATE:          out std_logic
            );
end entity;

architecture voice_allocator_impl of voice_allocator is
    function key_to_freq(key: keys_signal)
    return time_signal is
    begin
        case key is
            when "000000" => return to_unsigned(87, time_bits);
            when "000001" => return to_unsigned(92, time_bits);
            when "000010" => return to_unsigned(97, time_bits);
            when "000011" => return to_unsigned(103, time_bits);
            when "000100" => return to_unsigned(109, time_bits);
            when "000101" => return to_unsigned(116, time_bits);
            when "000110" => return to_unsigned(123, time_bits);
            when "000111" => return to_unsigned(130, time_bits);
            when "001000" => return to_unsigned(138, time_bits);
            when "001001" => return to_unsigned(146, time_bits);
            when "001010" => return to_unsigned(155, time_bits);
            when "001011" => return to_unsigned(164, time_bits);
            when "001100" => return to_unsigned(174, time_bits);
            when "001101" => return to_unsigned(184, time_bits);
            when "001110" => return to_unsigned(195, time_bits);
            when "001111" => return to_unsigned(206, time_bits);
            when "010000" => return to_unsigned(219, time_bits);
            when "010001" => return to_unsigned(232, time_bits);
            when "010010" => return to_unsigned(246, time_bits);
            when "010011" => return to_unsigned(260, time_bits);
            when "010100" => return to_unsigned(276, time_bits);
            when "010101" => return to_unsigned(292, time_bits);
            when "010110" => return to_unsigned(310, time_bits);
            when "010111" => return to_unsigned(328, time_bits);
            when "011000" => return to_unsigned(348, time_bits);
            when "011001" => return to_unsigned(368, time_bits);
            when "011010" => return to_unsigned(390, time_bits);
            when "011011" => return to_unsigned(413, time_bits);
            when "011100" => return to_unsigned(438, time_bits);
            when "011101" => return to_unsigned(464, time_bits);
            when "011110" => return to_unsigned(492, time_bits);
            when "011111" => return to_unsigned(521, time_bits);
            when "100000" => return to_unsigned(552, time_bits);
            when "100001" => return to_unsigned(585, time_bits);
            when "100010" => return to_unsigned(620, time_bits);
            when "100011" => return to_unsigned(656, time_bits);
            when "100100" => return to_unsigned(696, time_bits);
            when others  => return (others => '0');
        end case;
    end function;

    type key_code_vector is array(num_voices - 1 downto 0) of keys_signal;
    subtype gate_vector is std_logic_vector(num_voices - 1 downto 0);
    signal freq_buf: time_signal := (others => '0');
    signal gate_buf: std_logic := '0';
    signal key_codes: key_code_vector := (others => (others => '0'));
    signal next_voice: unsigned(voices_bits - 1 downto 0) := (others=>'0');
    signal current_voice: unsigned(voices_bits - 1 downto 0) := (others=>'0');
    signal gates: gate_vector := (others => '0');

begin
    process(CLK)
        variable voice_aux: unsigned(voices_bits - 1 downto 0)
            := (others => '0');
        variable freq_aux: time_signal := (others => '0');
    begin
        if EN = '1' and rising_edge(CLK) then
            if OCTAVER = '1' then
                case KEY_EVENT is
                    when key_event_make =>
                        key_codes(to_integer(next_voice)) <= KEY_CODE;
                        gates(to_integer(next_voice)) <= '1';
                        voice_aux := next_voice + 1;
                        next_voice <= '0' & voice_aux(voices_bits - 2 downto 0);
                    when key_event_break =>
                        for i in key_codes'low to key_codes'high loop
                            if key_codes(i) = KEY_CODE then
                                gates(i) <= '0';
                            end if;
                        end loop;
                    when others =>
                        null;
                end case;

                if current_voice(voices_bits - 1) = '0' then
                    freq_buf <= key_to_freq(key_codes(to_integer(current_voice)));
                    gate_buf <= gates(to_integer(current_voice));
                else
                    voice_aux := '0' & current_voice(voices_bits - 2 downto 0);
                    freq_aux := key_to_freq(key_codes(to_integer(voice_aux)));
                    freq_buf <= freq_aux(time_bits - 2 downto 0) & '0';
                    gate_buf <= gates(to_integer(voice_aux));
                end if;
                current_voice <= current_voice + 1;
            else
                case KEY_EVENT is
                    when key_event_make =>
                        key_codes(to_integer(next_voice)) <= KEY_CODE;
                        gates(to_integer(next_voice)) <= '1';
                        next_voice <= next_voice + 1;
                    when key_event_break =>
                        for i in key_codes'low to key_codes'high loop
                            if key_codes(i) = KEY_CODE then
                                gates(i) <= '0';
                            end if;
                        end loop;
                    when others =>
                        null;
                end case;

                freq_buf <= key_to_freq(key_codes(to_integer(current_voice)));
                gate_buf <= gates(to_integer(current_voice));
                current_voice <= current_voice + 1;
            end if;
        end if;
    end process;

    FREQ <= freq_buf;
    GATE <= gate_buf;

end architecture;
