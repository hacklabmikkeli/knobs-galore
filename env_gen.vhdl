library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity env_gen is
    port    (CLK:           in  std_logic
            ;GATE:          in  std_logic
            ;A_RATE:        in  ctl_signal
            ;D_RATE:        in  ctl_signal
            ;S_LVL:         in  ctl_signal
            ;R_RATE:        in  ctl_signal
            ;ENV:           out ctl_signal
            ;BUSY:          out std_logic
            )
    ;
end entity;

architecture env_gen_impl of env_gen is
    type stage_t is (attack, decay, sustain, rel);
    constant zero_f : freq_signal := (others => '0');
    constant zero_c : ctl_signal := (others => '0');
    constant freq_max_val : freq_signal := to_unsigned(freq_max - 1, freq_bits);
    constant bit_diff : natural := freq_bits - ctl_bits - 1;
    constant zero_f_min_c : unsigned(bit_diff downto 0) := (others => '0');
    signal stage : stage_t := rel;
    signal prev_gate : std_logic := '0';
    signal counter : freq_signal := zero_f;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then

            if prev_gate = '0' and GATE = '1' then
                stage <= attack;
                prev_gate <= '1';
            elsif prev_gate = '1' and GATE = '0' then
                stage <= rel;
                prev_gate <= '0';
            end if;

            case stage is
                when attack =>
                    if counter > freq_max_val - A_RATE then
                        counter <= freq_max_val;
                        stage <= decay;
                    else
                        counter <= counter + A_RATE;
                    end if;
                when decay =>
                    if counter < (S_LVL & zero_f_min_c) + D_RATE then
                        counter <= S_LVL & zero_f_min_c;
                        stage <= sustain;
                    else
                        counter <= counter - D_RATE;
                    end if;
                when sustain =>
                    null;
                when rel =>
                    if counter < R_RATE then
                        counter <= zero_f;
                    else
                        counter <= counter - R_RATE;
                    end if;
            end case;
        end if;
    end process;

    ENV <= counter(counter'high downto counter'high - ENV'length + 1);
    BUSY <= '0' when counter = zero_f else '1';

end architecture;
