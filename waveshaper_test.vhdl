library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity waveshaper_test is
end entity;

architecture waveshaper_test_impl of waveshaper_test is
    signal  THETA:  ctl_signal := to_unsigned(0, ctl_bits);
    signal  Z:      ampl_signal;
begin
    waveshaper_sin : entity work.waveshaper(waveshaper_sin)
                     port map (THETA, Z);

    process begin
        for k in 0 to ctl_max - 1 loop
            THETA <= to_unsigned(k, ctl_bits);
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
