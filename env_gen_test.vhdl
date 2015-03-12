library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity env_gen_test is
end entity;

architecture env_gen_test_impl of env_gen_test is
    signal  CLK:            std_logic := '0';
    signal  GATE:           std_logic := '0';
    signal  A_RATE:         ctl_signal := x"FF";
    signal  D_RATE:         ctl_signal := x"02";
    signal  S_LVL:          ctl_signal := x"80";
    signal  R_RATE:         ctl_signal := x"10";
    signal  ENV:            time_signal := (others => '0');
    signal  STAGE:          adsr_stage := adsr_rel;
    signal  PREV_GATE:      std_logic := '0';
    signal  BUSY:           std_logic;
    constant length:        integer := 100000;

begin
    env_gen : entity 
                work.env_gen(env_gen_impl)
              port map 
                (CLK
                ,GATE
                ,A_RATE
                ,D_RATE
                ,S_LVL
                ,R_RATE
                ,ENV
                ,ENV
                ,STAGE
                ,STAGE
                ,PREV_GATE
                ,PREV_GATE
                );

    process begin
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        GATE <= '1';
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        GATE <= '0';
        for k in 0 to length loop
            CLK <= not CLK;
            wait for 1 ns;
        end loop;
        assert false report "end of test" severity note;
        wait;
    end process;
end architecture;
