library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity phase_distort_test is
end entity;

architecture phase_distort_test_impl of phase_distort_test is
    signal      CLK:            std_logic := '0';
    signal      CUTOFF:         ctl_signal := to_unsigned(0, ctl_bits);
    signal      THETA_IN:       ctl_signal := to_unsigned(0, ctl_bits);
    signal      SAW_THETA:      ctl_signal;
    signal      SQR_THETA:      ctl_signal;

begin
    phase_distort_saw : 
        entity work.phase_distort(phase_distort_saw)
        port map (CLK, CUTOFF, THETA_IN, SAW_THETA);

    phase_distort_sq : 
        entity work.phase_distort(phase_distort_sq)
        port map (CLK, CUTOFF, THETA_IN, SQR_THETA);

    process begin
        for j in 0 to (ctl_max - 1) / 16 loop
            CUTOFF <= to_unsigned(j * 16, CUTOFF'length);
            for i in 0 to (ctl_max - 1) / 16 loop
                THETA_IN <= to_unsigned(i * 16, THETA_IN'length);
                wait for 1 ns;
                CLK <= not CLK;
                wait for 1 ns;
                CLK <= not CLK;
                wait for 1 ns;
            end loop;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
