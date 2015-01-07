library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity phase_gen_test is
end entity;

architecture phase_gen_test_impl of phase_gen_test is
    signal  CLK:            std_logic := '0';
    signal  RESET:          std_logic := '0';
    signal  FREQ1:          freq_signal := x"0100";
    signal  FREQ2:          freq_signal := x"0188";
    signal  THETA:          ctl_signal;
    signal  SEL:            std_logic;
    constant length:        integer := 100000;

begin
    phase_gen : entity work.phase_gen(phase_gen_impl)
                port map (CLK,RESET,FREQ1,FREQ2,THETA,SEL);

    process begin
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
