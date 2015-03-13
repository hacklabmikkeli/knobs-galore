ANALYZE_FLAGS=-g
ELABORATE_FLAGS=-g
RUN_FLAGS=

VHDL=$(shell find *.vhdl)
TEST_VHDL=$(shell find *_test.vhdl)
OBJ=$(VHDL:.vhdl=.o)
TEST_VCD=$(TEST_VHDL:.vhdl=.vcd)

all: $(OBJ)

test: $(TEST_VCD)

clean:
	rm -f *.o *.vcd *.cf *.out

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

circular_buffer.o: common.o

circular_buffer_test.o: common.o circular_buffer.o

synthesizer.o: common.o env_gen.o delta_sigma_dac.o phase_distort.o phase_gen.o waveshaper.o

synthesizer_test.o: common.o synthesizer.o

synthesizer_sim.o: common.o env_gen.o delta_sigma_dac.o phase_distort.o phase_gen.o waveshaper.o

synthesizer_sim_test.o: common.o synthesizer_sim.o

.PHONY: all test clean
