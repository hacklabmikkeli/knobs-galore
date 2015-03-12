library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity waveform_test is
end entity;

architecture waveform_test_impl of waveform_test is
    signal      CLK:            std_logic  := '1';
    signal      CUTOFF:         ctl_signal := (others => '0');
    signal      THETA_IN:       ctl_signal := (others => '0');
    signal      SAW_THETA:      ctl_signal := (others => '0');
    signal      SQR_THETA:      ctl_signal := (others => '0');
    signal      SAW_Z:          ctl_signal;
    signal      SQR_Z:          ctl_signal;

begin
    phase_distort_saw : 
        entity work.phase_distort(phase_distort_saw)
        port map ('1', CLK, CUTOFF, THETA_IN, SAW_THETA);

    phase_distort_sq : 
        entity work.phase_distort(phase_distort_sq)
        port map ('1', CLK, CUTOFF, THETA_IN, SQR_THETA);

    waveform_saw :
        entity work.waveshaper(waveshaper_sin)
        port map ('1', CLK, SAW_THETA, SAW_Z);

    waveform_sq :
        entity work.waveshaper(waveshaper_sin)
        port map ('1', CLK, SQR_THETA, SQR_Z);

    process begin
        for j in 0 to ctl_max - 1 loop
            CUTOFF <= to_unsigned(j, CUTOFF'length);
            for i in 0 to ctl_max - 1 loop
                THETA_IN <= to_unsigned(i, THETA_IN'length);
                CLK <= not CLK;
                wait for 1 ns;
                CLK <= not CLK;
                wait for 1 ns;
            end loop;
        end loop;
        report "end of test" severity note;
        wait;
    end process;
end architecture;
