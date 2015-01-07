library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity input_sensor is
    port    (CLK:           in  std_logic
            ;INPUT_LINE:    in  std_logic
            ;INPUT_VALUES:  out all_inputs
            ;PROBE:         out std_logic
            ;INPUT_SEL:     out std_logic_vector(num_inputs)
            )
    ;
end entity;

architecture rc_sensor_impl of rc_sensor is
    function empty_inputs
    return all_inputs is
        variable retval : all_inputs;
    begin
        for i in all_inputs'range loop
            retval(i) := (others => 0);
        end loop;
    end function;

    signal ones : unsigned(input_bits + 3 downto 0) := (others => '0');
    signal bits : unsigned(input_bits + 3 downto 0) := (others => '0');
    signal sel : unsigned(num_inputs_bits - 1 downto 0) := (others => '0');
    signal probe_counter : input_signal := (others => '0');
    signal result : all_inputs := empty_inputs;
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if INPUT_LINE = '1' then
                ones <= ones + 1;
            end if;
            bits <= bits + 1;
            if bits = (others => '0') then
                result(to_integer(sel)) <= ones(input_bits + 3 downto 4);
                sel <= sel + 1;
                ones <= (others => '0');
            end if;

            probe_counter <= probe_counter + 1;
        end if;
    end process;

    input_sel <= 
end architecture;
