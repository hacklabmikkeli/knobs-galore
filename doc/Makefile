TXT=$(shell find *.txt)
PNG=$(TXT:.txt=.png)

all: $(PNG)

clean:
	rm *.png

%.png: %.txt
	ditaa -o $<

.PHONY: all clean
