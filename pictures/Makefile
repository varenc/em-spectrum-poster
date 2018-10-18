
all: emr.pdf

emr.pdf: emr.tex
	latex emrmaster.tex
	dvips  -Ppdf -G0 emrmaster.dvi -f > emrmaster.eps
	ps2pdf emrmaster.eps
	acroread emrmaster.pdf&

waves: waves.c
	cc -lm -o waves waves.c
