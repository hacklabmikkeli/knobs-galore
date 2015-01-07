library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity synthesizer is
    port (CLK:              in  std_logic
         ;KEYS:             in  std_logic_vector(7 downto 0)
         ;LINE_LEFT_POS:    out std_logic
         ;LINE_LEFT_NEG:    out std_logic
         )
    ;
end entity;

architecture synthesizer_impl of synthesizer is
    function keys_to_freq(keys : std_logic_vector(7 downto 0))
    return freq_signal is
    begin
        case keys is
            when "00000001" => return to_unsigned(262, freq_bits);
            when "00000010" => return to_unsigned(294, freq_bits);
            when "00000100" => return to_unsigned(330, freq_bits);
            when "00001000" => return to_unsigned(349, freq_bits);
            when "00010000" => return to_unsigned(392, freq_bits);
            when "00100000" => return to_unsigned(440, freq_bits);
            when "01000000" => return to_unsigned(494, freq_bits);
            when "10000000" => return to_unsigned(523, freq_bits);
            when others     => return to_unsigned(0, freq_bits);
        end case;
    end function;

    function lfo_val(lfo : unsigned(ctl_bits + 10 downto 0))
    return ctl_signal is
    begin
        case lfo(ctl_bits + 10) is
            when '0' => return "11" & lfo(lfo'high - 1 downto lfo'high - ctl_bits + 2);
            when '1' => return "11" & not lfo(lfo'high - 1 downto lfo'high - ctl_bits + 2);
            when others => return (others => '0');
        end case;
    end function;

    function gated(sgn : std_logic
                  ;keys : std_logic_vector(7 downto 0)
                  )
    return std_logic is
    begin
        return sgn and (keys(7) or
             keys(6) or
             keys(5) or
             keys(4) or
             keys(3) or
             keys(2) or
             keys(1) or
             keys(0));
    end function;


    signal lfo : unsigned(ctl_bits + 10 downto 0) := (others => '0');
    signal counter : unsigned(8 downto 0) := "000000000";
    signal CLK1 : std_logic := '0';
    signal CLK2 : std_logic := '0';
    signal theta : ctl_signal := (others => '0');
    signal theta_pd : ctl_signal := (others => '0');
    signal z : ampl_signal := (others => '0');
	signal v_out : std_logic;
begin

    process (CLK)
    begin
        if rising_edge(CLK) then
            if counter = to_unsigned(488, 9) then
               counter <= "000000000";
                lfo <= lfo + 1;
            else
               counter <= counter + 1;
            end if;
        end if;
    end process;

    CLK1 <= CLK;
    CLK2 <= '1' when counter = "000000000" else '0';

    phase_gen : entity work.phase_gen (phase_gen_impl)
                port map (CLK2, '0', keys_to_freq(KEYS), keys_to_freq(KEYS), theta, open);

    phase_distort : entity work.phase_distort (phase_distort_saw)
                    port map (lfo_val(lfo), theta, theta_pd);

    waveshaper : entity work.waveshaper(waveshaper_sin)
                 port map (theta_pd, z);

	dac : entity work.delta_sigma_dac(delta_sigma_dac_impl)
	      port map (CLK1, z, v_out);

    LINE_LEFT_NEG <= not gated(v_out, KEYS);
    LINE_LEFT_POS <= gated(v_out, KEYS);

		
end architecture;
