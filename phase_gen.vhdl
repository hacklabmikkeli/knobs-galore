library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity phase_gen is
    port    (CLK:           in  std_logic
            ;RESET:         in  std_logic
            ;FREQ1:         in  freq_signal
            ;FREQ2:         in  freq_signal
            ;THETA:         out ctl_signal
            ;SEL:           out std_logic
            )
    ;
end entity;

architecture phase_gen_impl of phase_gen is
    constant f_zero: freq_signal := to_unsigned(0, freq_bits);

    signal i_sel: std_logic := '1';
    signal i_cnt1: freq_signal := f_zero;
    signal i_cnt2: freq_signal := f_zero;

begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            i_sel <= '1';
            i_cnt1 <= f_zero;
            i_cnt2 <= f_zero;
        elsif rising_edge(CLK) then
            i_cnt1 <= i_cnt1 + FREQ1;
            i_cnt2 <= i_cnt2 + FREQ2;
            if i_cnt1 = f_zero then
                i_cnt2 <= f_zero;
                i_sel <= not i_sel;
            end if;
        end if;
    end process;

    THETA <=   i_cnt1(i_cnt1'high downto i_cnt1'high-THETA'length+1)
               when i_sel = '0'
               else i_cnt2(i_cnt2'high downto i_cnt2'high-THETA'length+1);

    SEL <= i_sel;

end architecture;
