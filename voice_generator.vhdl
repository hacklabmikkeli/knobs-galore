--
--    Knobs Galore - a free phase distortion synthesizer
--    Copyright (C) 2015 Ilmo Euro
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity voice_generator is
    port    (EN:            in  std_logic
            ;CLK:           in  std_logic
            ;FREQ:          in  time_signal
            ;GATE:          in  std_logic
            ;PARAMS:        in  synthesis_params
            ;AUDIO_OUT:     out ctl_signal
            ;OUT_TO_FIFO:   out state_vector_t
            ;IN_FROM_FIFO:  in  state_vector_t
            );
end entity;

architecture voice_generator_impl of voice_generator is

    signal s1_cutoff: time_signal;
    signal s1_cutoff_stage: adsr_stage;
    signal s1_cutoff_prev_gate: std_logic;

    signal s1_gain: time_signal;
    signal s1_gain_stage: adsr_stage;
    signal s1_gain_prev_gate: std_logic;

    signal s1_phase: time_signal;

    signal s3_wf: waveform_t;
    signal s3_cutoff: ctl_signal;
    signal s3_theta: ctl_signal;
    signal s3_gain: ctl_signal;

    signal s7_theta: ctl_signal;
    signal s7_gain: ctl_signal;

    signal s8_z: ctl_signal;
    signal s8_gain: ctl_signal;

    signal s9_z_ampl: ctl_signal;

    signal s1_freq: time_signal := (others=>'0');

begin

    process(CLK)
    begin
        if EN='1' and rising_edge(clk) then
            s1_freq <= FREQ;
        end if;
    end process;

    phase_gen:
        entity
            work.phase_gen (phase_gen_impl)
        port map
            ('1'
            ,CLK
            ,IN_FROM_FIFO.sv_phase
            ,s1_phase
            );

    env_gen_cutoff:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,CLK
            ,GATE
            ,PARAMS.sp_cutoff_base
            ,PARAMS.sp_cutoff_env
            ,PARAMS.sp_cutoff_attack
            ,PARAMS.sp_cutoff_decay
            ,PARAMS.sp_cutoff_sustain
            ,PARAMS.sp_cutoff_rel
            ,IN_FROM_FIFO.sv_cutoff
            ,s1_cutoff
            ,IN_FROM_FIFO.sv_cutoff_stage
            ,s1_cutoff_stage
            ,IN_FROM_FIFO.sv_cutoff_prev_gate
            ,s1_cutoff_prev_gate
            );

    env_gen_gain:
        entity
            work.env_gen (env_gen_impl)
        port map
            ('1'
            ,CLK
            ,GATE
            ,x"00"
            ,x"FF"
            ,PARAMS.sp_gain_attack
            ,PARAMS.sp_gain_decay
            ,PARAMS.sp_gain_sustain
            ,PARAMS.sp_gain_rel
            ,IN_FROM_FIFO.sv_gain
            ,s1_gain
            ,IN_FROM_FIFO.sv_gain_stage
            ,s1_gain_stage
            ,IN_FROM_FIFO.sv_gain_prev_gate
            ,s1_gain_prev_gate
            );

    voice_controller:
        entity
            work.voice_controller (voice_controller_impl)
        port map
            ('1'
            ,CLK
            ,PARAMS.sp_mode
            ,FREQ
            ,s1_cutoff
            ,s3_cutoff
            ,s1_gain
            ,s3_gain
            ,s1_phase
            ,s3_theta
            ,s3_wf
            );


    phase_distort:
        entity 
            work.phase_distort (phase_distort_impl)
        port map
            ('1'
            ,CLK
            ,s3_wf
            ,s3_cutoff
            ,s3_theta
            ,s7_theta
            ,s3_gain
            ,s7_gain
            );

    waveshaper:
        entity
            work.waveshaper(waveshaper_sin)
        port map
            ('1'
            ,CLK
            ,s7_theta
            ,s8_z
            ,s7_gain
            ,s8_gain
            );

    amplifier:
        entity
            work.amplifier (amplifier_impl)
        port map
            ('1'
            ,CLK
            ,s8_gain
            ,s8_z
            ,s9_z_ampl
            );

    AUDIO_OUT <= s9_z_ampl;
    OUT_TO_FIFO <= 
                  (s1_phase
                  ,s1_gain
                  ,s1_gain_stage
                  ,s1_gain_prev_gate
                  ,s1_cutoff
                  ,s1_cutoff_stage
                  ,s1_cutoff_prev_gate
                  );
end architecture;
