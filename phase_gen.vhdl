library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity phase_gen is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;FREQ1:         in  time_signal
            ;FREQ2:         in  time_signal
            ;PHASE1_IN:     in  time_signal
            ;PHASE2_IN:     in  time_signal
            ;WAVE_SEL_IN:   in  std_logic
            ;PHASE1_OUT:    out time_signal
            ;PHASE2_OUT:    out time_signal
            ;WAVE_SEL_OUT:  out std_logic
            )
    ;
end entity;

architecture phase_gen_impl of phase_gen is
    signal phase1_out_buf: time_signal := (others => '0');
    signal phase2_out_buf: time_signal := (others => '0');
    signal wave_sel_out_buf: std_logic := '0';

begin
    process(CLK)
        variable overflow_check: unsigned(time_bits downto 0);
    begin
        if EN = '1' and rising_edge(CLK) then
            overflow_check := ('0' & PHASE1_IN) + ('0' & FREQ1);

            if overflow_check(overflow_check'high) = '1' then
                wave_sel_out_buf <= not WAVE_SEL_IN;
                phase1_out_buf <= (others => '0');
                phase2_out_buf <= (others => '0');
            else
                wave_sel_out_buf <= WAVE_SEL_IN;
                phase1_out_buf <= PHASE1_IN + FREQ1;
                phase2_out_buf <= PHASE2_IN + FREQ2;
            end if;
        end if;
    end process;

    PHASE1_OUT <= phase1_out_buf;
    PHASE2_OUT <= phase2_out_buf;
    WAVE_SEL_OUT <= wave_sel_out_buf;

end architecture;
