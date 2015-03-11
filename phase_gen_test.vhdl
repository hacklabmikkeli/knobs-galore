library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity phase_gen_test is
end entity;

architecture phase_gen_test_impl of phase_gen_test is
    signal  CLK:            std_logic := '0';
    signal  FREQ1:          time_signal := ('0', '0', '0', '0', '1', others => '0');
    signal  FREQ2:          time_signal := ('0', '0', '0', '1', others => '0');
    signal  THETA1:         time_signal := (others => '0');
    signal  THETA2:         time_signal := (others => '0');
    signal  WAVE_SEL:       std_logic := '0';
    constant length:        integer := 100000;

begin
    phase_gen : entity
                    work.phase_gen(phase_gen_impl)
                port map
                    (CLK
                    ,FREQ1
                    ,FREQ2
                    ,THETA1
                    ,THETA2
                    ,WAVE_SEL
                    ,THETA1
                    ,THETA2
                    ,WAVE_SEL
                    );

    process begin
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
