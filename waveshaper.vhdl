library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity waveshaper is
    port    (CLK:           in  std_logic
            ;THETA:         in  ctl_signal
            ;Z:             out ctl_signal
            )
    ;
end entity;

architecture waveshaper_sin of waveshaper is

    type lut_t is array(0 to (ctl_max/4) - 1) of ctl_signal;

    function init_sin_lut return lut_t is
        constant N : real := real(ctl_max);
        variable theta, z : real;
        variable z_int : integer;
        variable retval : lut_t;
    begin
        for k in lut_t'low to lut_t'high loop
            theta := (real(k) / N) * 2.0 * MATH_PI;
            z := (sin(theta) * 0.5) + 0.5;
            z_int := integer(z * real(ctl_max));
            if z_int < 0 then
                z_int := 0;
            elsif z_int > (ctl_max - 1) then
                z_int := (ctl_max - 1);
            end if;
            retval(k) := to_unsigned(z_int, ctl_bits);
        end loop;
        return retval;
    end function init_sin_lut;

    constant sin_lut : lut_t := init_sin_lut;

    function lookup(theta: ctl_signal; lut: lut_t)
    return ctl_signal is
        constant phase_max : integer := ctl_max / 4;
        variable quadrant : unsigned(1 downto 0);
        variable phase : integer;
    begin
        quadrant := theta(ctl_bits-1 downto ctl_bits-2);
        phase := to_integer(theta(ctl_bits-3 downto 0));
        case theta(ctl_bits-1 downto ctl_bits-2) is
            when "00" =>
                return lut(phase);
            when "01" =>
                return lut(phase_max - 1 - phase);
            when "10" =>
                return not (lut(phase)); -- negate
            when others =>
                return not (lut(phase_max - 1 - phase)); -- negate
        end case;
    end function;

    signal z_buf: ctl_signal := (others => '0');
begin
    process (CLK)
    begin
        z_buf <= lookup(THETA, sin_lut);
    end process;

    Z <= z_buf;
end architecture;
