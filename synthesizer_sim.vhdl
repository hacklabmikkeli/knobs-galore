library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.common.all;

entity synthesizer_sim is
    port (CLK:              in  std_logic
         ;KEYS:             in  std_logic_vector(7 downto 0)
         ;AUDIO:            out ctl_signal
         )
    ;
end entity;

architecture synthesizer_sim_impl of synthesizer_sim is
    function keys_to_freq(keys : std_logic_vector(7 downto 0))
    return time_signal is
    begin
        case keys is
            when "00000001" => return to_unsigned(262, time_bits);
            when "00000010" => return to_unsigned(294, time_bits);
            when "00000100" => return to_unsigned(330, time_bits);
            when "00001000" => return to_unsigned(349, time_bits);
            when "00010000" => return to_unsigned(392, time_bits);
            when "00100000" => return to_unsigned(440, time_bits);
            when "01000000" => return to_unsigned(494, time_bits);
            when "10000000" => return to_unsigned(523, time_bits);
            when others     => return to_unsigned(0, time_bits);
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

    signal ENV: time_signal := (others => '0');
    signal STAGE: adsr_stage := adsr_rel;
    signal GATE: std_logic := '0';
    signal PREV_GATE: std_logic := '0';
    signal theta : time_signal := (others => '0');
    signal theta_pd : ctl_signal := (others => '0');
    signal z : ctl_signal := (others => '0');
	signal v_out : std_logic;
begin

    GATE <= '1' when keys /= "00000000" else '0';

    phase_gen : entity
                    work.phase_gen (phase_gen_impl)
                port map
                    ('1'
                    ,CLK
                    ,keys_to_freq(KEYS)
                    ,keys_to_freq(KEYS)
                    ,theta
                    ,(others => '0')
                    ,'0'
                    ,theta
                    ,open
                    ,open
                    );

    env_gen : entity
                work.env_gen (env_gen_impl)
              port map
                ('1'
                ,CLK
                ,GATE
                ,x"08"
                ,x"01"
                ,x"00"
                ,x"FF"
                ,ENV
                ,ENV
                ,STAGE
                ,STAGE
                ,PREV_GATE
                ,PREV_GATE
                );

    phase_distort : entity 
                        work.phase_distort (phase_distort_saw)
                    port map
                        ('1'
                        ,CLK
                        ,ENV(15 downto 8)
                        ,theta(15 downto 8)
                        ,theta_pd
                        );

    waveshaper : entity
                    work.waveshaper(waveshaper_sin)
                 port map
                    ('1'
                    ,CLK
                    ,theta_pd
                    ,z
                    );

    AUDIO <= z;
end architecture;
