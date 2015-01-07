library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity delta_sigma_dac is
    port    (CLK:           in  std_logic
            ;Zin:           in  ampl_signal
            ;Vout:          out std_logic
            )
    ;
end entity;

architecture delta_sigma_dac_impl of delta_sigma_dac is
    subtype sigma_t is signed(ampl_signal'high + 1 downto 0);

    signal sigma : sigma_t := (others => '0');

begin
    process (CLK)
        variable delta : sigma_t;
        variable zin_s : sigma_t;
    begin
        if rising_edge(CLK) then
            zin_s := signed("0" & Zin);
            delta := ('0', others => not sigma(sigma'left));
            sigma <= (sigma + zin_s) - delta;
        end if;
    end process;

    Vout <= not sigma(sigma'left);
end architecture;
