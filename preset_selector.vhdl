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

entity preset_selector is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;KEY_CODE:      in  keys_signal
            ;KEY_EVENT:     in  key_event_t
            ;PARAMS:        out synthesis_params
            );
end entity;

architecture preset_selector_impl of preset_selector is
    subtype quantized_t is unsigned(2 downto 0); 

    function time_unquantize(quantized: quantized_t)
    return ctl_signal is
    begin
        case quantized is
            when "000" => return x"01";
            when "001" => return x"02";
            when "010" => return x"04";
            when "011" => return x"08";
            when "100" => return x"10";
            when "101" => return x"20";
            when "110" => return x"80";
            when "111" => return x"F0";
            when others => return x"FF";
        end case;
    end function;

    function level_unquantize(quantized: quantized_t)
    return ctl_signal is
    begin
        case quantized is
            when "000" => return x"00";
            when "001" => return x"20";
            when "010" => return x"40";
            when "011" => return x"60";
            when "100" => return x"80";
            when "101" => return x"A0";
            when "110" => return x"C0";
            when "111" => return x"E0";
            when others => return x"FF";
        end case;
    end function;

    signal mode: mode_t                     := mode_saw;
    signal transform: voice_transform_t     := voice_transform_none;
    signal q_cutoff_base: quantized_t       := "000";
    signal q_cutoff_env: quantized_t        := "111";
    signal q_cutoff_attack: quantized_t     := "111";
    signal q_cutoff_decay: quantized_t      := "000";
    signal q_cutoff_sustain: quantized_t    := "111";
    signal q_cutoff_rel: quantized_t        := "111";
    signal q_gain_attack: quantized_t       := "111";
    signal q_gain_decay: quantized_t        := "111";
    signal q_gain_sustain: quantized_t      := "111";
    signal q_gain_rel: quantized_t          := "111";

begin
    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            if KEY_EVENT = key_event_make then
                case KEY_CODE is
                    -- Preset editing
                    when "001100" => mode <= mode + 1;
                    when "001101" => mode <= mode - 1;
                    when "100011" => transform <= transform + 1;
                    when "100000" => transform <= transform - 1;
                    when "001111" => q_cutoff_base <= q_cutoff_base + 1;
                    when "001110" => q_cutoff_base <= q_cutoff_base - 1;
                    when "100010" => q_cutoff_env <= q_cutoff_env + 1;
                    when "100001" => q_cutoff_env <= q_cutoff_env - 1;
                    when "000010" => q_cutoff_attack <= q_cutoff_attack + 1;
                    when "000011" => q_cutoff_attack <= q_cutoff_attack - 1;
                    when "000001" => q_cutoff_decay <= q_cutoff_decay + 1;
                    when "000000" => q_cutoff_decay <= q_cutoff_decay - 1;
                    when "000111" => q_cutoff_sustain <= q_cutoff_sustain + 1;
                    when "000110" => q_cutoff_sustain <= q_cutoff_sustain - 1;
                    when "000101" => q_cutoff_rel <= q_cutoff_rel + 1;
                    when "000100" => q_cutoff_rel <= q_cutoff_rel - 1;
                    when "010000" => q_gain_attack <= q_gain_attack + 1;
                    when "010001" => q_gain_attack <= q_gain_attack - 1;
                    when "010010" => q_gain_decay <= q_gain_decay + 1;
                    when "010011" => q_gain_decay <= q_gain_decay - 1;
                    when "010111" => q_gain_sustain <= q_gain_sustain + 1;
                    when "010110" => q_gain_sustain <= q_gain_sustain - 1;
                    when "010101" => q_gain_rel <= q_gain_rel + 1;
                    when "010100" => q_gain_rel <= q_gain_rel - 1;

                    -- Factory presets
                    when "011000" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011001" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011010" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011011" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011100" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011101" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011110" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when "011111" =>
                        mode <= mode_saw;
                        transform <= voice_transform_none;
                        q_cutoff_base <= "000";
                        q_cutoff_env <= "000";
                        q_cutoff_attack <= "000";
                        q_cutoff_decay <= "000";
                        q_cutoff_sustain <= "000";
                        q_cutoff_rel <= "000";
                        q_gain_attack <= "000";
                        q_gain_decay <= "000";
                        q_gain_sustain <= "000";
                        q_gain_rel <= "000";
                    when others   => null;
                end case;
            end if;
        end if;
    end process;

    PARAMS <= (mode
              ,transform
              ,level_unquantize(q_cutoff_base)
              ,level_unquantize(q_cutoff_env)
              ,time_unquantize(q_cutoff_attack)
              ,time_unquantize(q_cutoff_decay)
              ,level_unquantize(q_cutoff_sustain)
              ,time_unquantize(q_cutoff_rel)
              ,time_unquantize(q_gain_attack)
              ,time_unquantize(q_gain_decay)
              ,level_unquantize(q_gain_sustain)
              ,time_unquantize(q_gain_rel)
              );

end architecture;
