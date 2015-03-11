
%.o: %.vhdl
	ghdl -a $^

%.vcd: %
	ghdl -r $^ --vcd=$@

phase_gen_test: common.o phase_gen.o phase_gen_test.o
	ghdl -e $@

env_gen_test: common.o env_gen.o env_gen_test.o
	ghdl -e $@

waveshaper_test: common.o waveshaper.o waveshaper_test.o
	ghdl -e $@

phase_distort_test: common.o phase_distort.o phase_distort_test.o
	ghdl -e $@

delta_sigma_dac_test: common.o waveshaper.o delta_sigma_dac.o delta_sigma_dac_test.o
	ghdl -e $@

waveform_test: common.o waveshaper.o phase_distort.o waveform_test.o
	ghdl -e $@

test: \
	phase_gen_test.vcd \
	env_gen_test.vcd \
	waveshaper_test.vcd \
	phase_distort_test.vcd \
	delta_sigma_dac_test.vcd \
	waveform_test.vcd

.PHONY: vcd
