library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity delta_sigma_dac_test is
end entity;

architecture delta_sigma_dac_test_impl of delta_sigma_dac_test is
    signal  THETA:  ctl_signal := (others => '0');
    signal  Zctl:   ctl_signal := (others => '0');
    signal  Z:      audio_signal := (others => '0');
    signal  CLK:    std_logic := '1';
    signal  Vout:   std_logic;
    constant count: natural := 30;
begin
    waveshaper_sin : entity work.waveshaper(waveshaper_sin)
                     port map ('1', CLK, THETA, Zctl);

    delta_sigma_dac : entity work.delta_sigma_dac(delta_sigma_dac_impl)
                     port map ('1', CLK, Z, Vout); 

    process begin
        for k in 0 to ctl_max - 1 loop
            THETA <= to_unsigned(k, ctl_bits);
            for i in 1 to count loop
                CLK <= not CLK;
                wait for 1 ns;
            end loop;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;

    Z <= to_audio_msb(Zctl);
end architecture;
