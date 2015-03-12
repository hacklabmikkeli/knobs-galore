# knobs-galore
VHDL source code for a simple phase distortion synthesizer

### Target hardware
The current target hardware for the synthesizer is [Papilio One](http://papilio.cc/).
Audio output is via a 3,5mm headphone jack (available as a module for Papilio) and
input is through a Simba My Music World toy keyboard.

### Test instructions (Linux/Unix/OSX)
You need to have ghdl (GCC VHDL frontend) and GtkWave installed. After that,
run `make test` in the project folder and inspect the `.vcd` file.

### Test instructions (Windows)
Would somebody with a Windows machine create a test script?

### Synthesis instructions
Create a Xilinx ISE (or Vivado) project and add non-test .vhdl files and the .ucf file
to the project, and synthesize like any other Xilinx project. Note that there's
no main entity at the moment, so the project can't be synthesized.

### More info
Info on phase distortion:

 * [WikiAudio](http://en.wikiaudio.org/Phase_distortion_synthesis)
 * [Patent](http://pdfpiw.uspto.gov/.piw?docid=04658691&PageNum=1&IDKey=EB1A4353946E&HomeUrl=http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1%2526Sect2=HITOFF%2526d=PALL%2526p=1%2526u=%25252Fnetahtml%25252FPTO%25252Fsrchnum.htm%2526r=1%2526f=G%2526l=50%2526s1=4658691.PN.%2526OS=PN/4658691%2526RS=PN/4658691)
