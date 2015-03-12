GHDL_FLAGS=-g

test: \
	phase_gen_test.vcd \
	env_gen_test.vcd \
	waveshaper_test.vcd \
	phase_distort_test.vcd \
	delta_sigma_dac_test.vcd \
	waveform_test.vcd

clean:
	rm *.o *.vcd

%.o: %.vhdl
	ghdl -a $(GHDL_FLAGS) $<

%.vcd: %.o
	ghdl -e $(subst .o,,$^)
	ghdl -r $(subst .o,,$^) --vcd="$(subst .o,.vcd,$^)"
	rm $(subst .o,,$^)

phase_gen.o: common.o

env_gen.o: common.o

waveshaper.o: common.o

phase_distort.o: common.o

delta_sigma_dac.o: common.o

phase_gen_test.o: common.o phase_gen.o

env_gen_test.o: common.o env_gen.o

waveshaper_test.o: common.o waveshaper.o

phase_distort_test.o: common.o phase_distort.o

delta_sigma_dac_test.o: common.o waveshaper.o delta_sigma_dac.o

waveform_test.o: common.o waveshaper.o phase_distort.o

.PHONY: test clean
