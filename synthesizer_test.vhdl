library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity synthesizer_test is
end entity;

architecture synthesizer_test_impl of synthesizer_test is
    type key_combination_table is array(integer range <>) of std_logic_vector(7 downto 0);

    constant key_combinations : key_combination_table(8 downto 0) :=
        ("00000000"
        ,"10000000"
        ,"01000000"
        ,"00100000"
        ,"00010000"
        ,"00001000"
        ,"00000100"
        ,"00000010"
        ,"00000001"
        );

    signal CLK:              std_logic := '1';
    signal KEYS:             std_logic_vector(7 downto 0) := key_combinations(0);
    signal LINE_LEFT_POS:    std_logic;
    signal LINE_LEFT_NEG:    std_logic;

begin

    synthesizer : entity work.synthesizer(synthesizer_impl)
                  port map (CLK, KEYS, LINE_LEFT_POS, LINE_LEFT_NEG);

    process begin
        for j in key_combinations'range loop
            KEYS <= key_combinations(j);
            for k in 1 to 320000 loop
                CLK <= not CLK;
                wait for 31.25 ns;
            end loop;
        end loop;
        report "end of test" severity note;
        wait;
    end process;
end architecture;
