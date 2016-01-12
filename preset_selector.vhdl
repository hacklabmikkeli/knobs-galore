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
    function select_preset(key: keys_signal)
    return synthesis_params is
        variable retval : synthesis_params := empty_synthesis_params;
    begin
        case key is
            when "000000" =>
                retval := 
                    (mode_saw_res
                    ,voice_transform_sub
                    ,x"00"
                    ,x"A0"
                    ,x"F0"
                    ,x"04"
                    ,x"00"
                    ,x"F0"
                    ,x"F0"
                    ,x"00"
                    ,x"FF"
                    ,x"F0"
                    );
            when "000001" =>
                retval := 
                    (mode_saw_fat
                    ,voice_transform_oct
                    ,x"00"
                    ,x"A0"
                    ,x"01"
                    ,x"F0"
                    ,x"A0"
                    ,x"F0"
                    ,x"F0"
                    ,x"00"
                    ,x"FF"
                    ,x"F0"
                    );
            when "000010" =>
                retval := 
                    (mode_mix
                    ,voice_transform_none
                    ,x"00"
                    ,x"08"
                    ,x"01"
                    ,x"F0"
                    ,x"80"
                    ,x"0A"
                    ,x"10"
                    ,x"00"
                    ,x"FF"
                    ,x"04"
                    );
            when "000011" =>
                retval := 
                    (mode_mix
                    ,voice_transform_none
                    ,x"00"
                    ,x"10"
                    ,x"01"
                    ,x"F0"
                    ,x"10"
                    ,x"F0"
                    ,x"10"
                    ,x"00"
                    ,x"FF"
                    ,x"04"
                    );
            when "000100" =>
                retval := 
                    (mode_sq_fat
                    ,voice_transform_sub
                    ,x"00"
                    ,x"A0"
                    ,x"08"
                    ,x"F0"
                    ,x"A0"
                    ,x"F0"
                    ,x"FF"
                    ,x"00"
                    ,x"FF"
                    ,x"FF"
                    );
            when "000101" =>
                retval := 
                    (mode_sq_fat
                    ,voice_transform_none
                    ,x"00"
                    ,x"A0"
                    ,x"F0"
                    ,x"04"
                    ,x"00"
                    ,x"F0"
                    ,x"FF"
                    ,x"01"
                    ,x"00"
                    ,x"FF"
                    );
            when "000110" =>
                retval := 
                    (mode_sq
                    ,voice_transform_none
                    ,x"40"
                    ,x"80"
                    ,x"02"
                    ,x"01"
                    ,x"70"
                    ,x"F0"
                    ,x"FF"
                    ,x"01"
                    ,x"00"
                    ,x"FF"
                    );
            when "000111" =>
                retval := 
                    (mode_sq_fat
                    ,voice_transform_sub
                    ,x"00"
                    ,x"A0"
                    ,x"F0"
                    ,x"04"
                    ,x"00"
                    ,x"F0"
                    ,x"FF"
                    ,x"01"
                    ,x"00"
                    ,x"FF"
                    );
            when "001000" =>
                retval := 
                    (mode_sq_fat
                    ,voice_transform_oct
                    ,x"10"
                    ,x"30"
                    ,x"01"
                    ,x"01"
                    ,x"30"
                    ,x"F0"
                    ,x"20"
                    ,x"F0"
                    ,x"FF"
                    ,x"FF"
                    );
            when "001001" =>
                retval := 
                    (mode_mix
                    ,voice_transform_none
                    ,x"00"
                    ,x"B0"
                    ,x"F0"
                    ,x"08"
                    ,x"00"
                    ,x"F0"
                    ,x"FF"
                    ,x"08"
                    ,x"00"
                    ,x"FF"
                    );
            when "001010" =>
                retval := 
                    (mode_mix
                    ,voice_transform_none
                    ,x"10"
                    ,x"B0"
                    ,x"01"
                    ,x"01"
                    ,x"00"
                    ,x"01"
                    ,x"04"
                    ,x"02"
                    ,x"00"
                    ,x"FF"
                    );
            when "001011" =>
                retval := 
                    (mode_saw_res
                    ,voice_transform_none
                    ,x"04"
                    ,x"20"
                    ,x"01"
                    ,x"01"
                    ,x"00"
                    ,x"01"
                    ,x"04"
                    ,x"02"
                    ,x"00"
                    ,x"FF"
                    );
            when "001100" =>
                retval := 
                    (mode_sq_res
                    ,voice_transform_none
                    ,x"00"
                    ,x"A0"
                    ,x"F0"
                    ,x"01"
                    ,x"00"
                    ,x"01"
                    ,x"F0"
                    ,x"01"
                    ,x"00"
                    ,x"FF"
                    );
            when "001101" =>
                retval := 
                    (mode_sq
                    ,voice_transform_oct
                    ,x"40"
                    ,x"80"
                    ,x"02"
                    ,x"01"
                    ,x"70"
                    ,x"F0"
                    ,x"FF"
                    ,x"01"
                    ,x"00"
                    ,x"FF"
                    );
            when "001110" =>
                retval := 
                    (mode_mix
                    ,voice_transform_oct
                    ,x"50"
                    ,x"90"
                    ,x"04"
                    ,x"01"
                    ,x"90"
                    ,x"F0"
                    ,x"10"
                    ,x"01"
                    ,x"FF"
                    ,x"FF"
                    );
            when others =>
                null;
        end case;
        return retval;
    end function;

    signal params_buf: synthesis_params := empty_synthesis_params;

begin
    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            if KEY_EVENT = key_event_make then
                params_buf <= select_preset(KEY_CODE);
            end if;
        end if;
    end process;

    PARAMS <= params_buf;

end architecture;
