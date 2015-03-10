library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity waveshaper_test is
end entity;

architecture waveshaper_test_impl of waveshaper_test is
    signal  CLK:    std_logic := '0';
    signal  THETA:  ctl_signal := (others => '0');
    signal  Z:      ctl_signal;
begin
    waveshaper_sin : entity work.waveshaper(waveshaper_sin)
                     port map (CLK, THETA, Z);

    process begin
        for k in 0 to ctl_max - 1 loop
            THETA <= to_unsigned(k, ctl_bits);
            CLK <= not CLK;
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
