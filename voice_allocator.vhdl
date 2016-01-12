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
            ;TRANSFORM:     in  voice_transform_t
            ;KEY_CODE:      in  keys_signal
            ;KEY_EVENT:     in  key_event_t
            ;FREQ:          out time_signal
            ;GATE:          out std_logic
            );
end entity;

architecture voice_allocator_impl of voice_allocator is
    function key_to_freq_int(key: keys_signal)
    return integer is
    begin
        case key is
            when "000000" => return 87;
            when "000001" => return 92;
            when "000010" => return 97;
            when "000011" => return 103;
            when "000100" => return 109;
            when "000101" => return 116;
            when "000110" => return 123;
            when "000111" => return 130;
            when "001000" => return 138;
            when "001001" => return 146;
            when "001010" => return 155;
            when "001011" => return 164;
            when "001100" => return 174;
            when "001101" => return 184;
            when "001110" => return 195;
            when "001111" => return 206;
            when "010000" => return 219;
            when "010001" => return 232;
            when "010010" => return 246;
            when "010011" => return 260;
            when "010100" => return 276;
            when "010101" => return 292;
            when "010110" => return 310;
            when "010111" => return 328;
            when "011000" => return 348;
            when "011001" => return 368;
            when "011010" => return 390;
            when "011011" => return 413;
            when "011100" => return 438;
            when "011101" => return 464;
            when "011110" => return 492;
            when "011111" => return 521;
            when "100000" => return 552;
            when "100001" => return 585;
            when "100010" => return 620;
            when "100011" => return 656;
            when "100100" => return 696;
            when others  => return 0;
        end case;
    end function;

    function key_to_freq(key: keys_signal)
    return time_signal is
    begin
        return to_unsigned(key_to_freq_int(key), time_bits);
    end function;

    function sub_key_to_freq(key: keys_signal)
    return time_signal is
    begin
        return to_unsigned(key_to_freq_int(key)/2, time_bits);
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
            case TRANSFORM is
                when voice_transform_oct =>
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
                when voice_transform_sub =>
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

                    freq_buf <= sub_key_to_freq(key_codes(to_integer(current_voice)));
                    gate_buf <= gates(to_integer(current_voice));
                    current_voice <= current_voice + 1;
                when others =>
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
            end case;
        end if;
    end process;

    FREQ <= freq_buf;
    GATE <= gate_buf;

end architecture;
