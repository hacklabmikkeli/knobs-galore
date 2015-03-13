library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity circular_buffer is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;DATA_IN:       in  state_vector
            ;DATA_OUT:      out state_vector
            );
end entity;

architecture circular_buffer_impl of circular_buffer is
    type data_buffer is array (0 to num_voices - 1) of state_vector;

    signal counter: natural range 0 to num_voices - 1 := 0;
    signal data_out_buf: state_vector := empty_state_vector;
    signal data: data_buffer := (others => empty_state_vector);

begin
    process(CLK)
    begin
        if EN = '1' and rising_edge(CLK) then
            data_out_buf <= data(counter);
            data(counter) <= DATA_IN;
            if counter = num_voices - 2 then
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    DATA_OUT <= data_out_buf;

end architecture;
