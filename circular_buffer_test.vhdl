library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity circular_buffer_test is
end entity;

architecture circular_buffer_test_impl of circular_buffer_test is
    signal  CLK:            std_logic := '1';
    signal  EN:             std_logic := '0';
    signal  PHASE:          time_signal;
    signal  DATA_IN:        state_vector := empty_state_vector;
    signal  DATA_OUT:       state_vector;
    constant length:        natural := 1000;

begin
    circular_buffer : entity 
                work.circular_buffer(circular_buffer_impl)
              port map 
                (EN
                ,CLK
                ,DATA_IN
                ,DATA_OUT
                );

    process
        variable sv : state_vector := empty_state_vector;

    begin
        for k in 0 to num_voices - 1 loop
            sv := empty_state_vector;
            sv.sv_phase1 := to_unsigned(k, time_bits);
            DATA_IN <= sv;

            EN <= '1';
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
            EN <= '0';
            wait for 1 ns;
        end loop;

        for k in 0 to length loop
            DATA_IN <= DATA_OUT;

            EN <= '1';
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
            CLK <= not CLK;
            wait for 1 ns;
            EN <= '0';
            wait for 1 ns;
        end loop;

        assert false report "end of test" severity note;
        wait;
    end process;

    PHASE <= DATA_OUT.sv_phase1;
end architecture;
