VERSION=0.18
NAME=spectrum
GS=gs

#for when "a drawing error occurred" in acroread
# GS=gs-gpl

all: numbers spectrum

# Make the spectrum chart
spectrum:
	latex tex/spectrum.tex
	dvips  -Ppdf -T 24in,36in spectrum.dvi -f > spectrum.eps
	#ps2pdf spectrum.eps spectrum_current.pdf
	/usr/bin/$(GS) -dSAFER -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=spectrum_current.pdf -dSAFER -c .setpdfwrite -f spectrum.eps
	acroread spectrum_current.pdf&


cmyk:
	gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
	-sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK \
	-sOutputFile=spectrum_20100428_cmyk.pdf spectrum_20100428_test.pdf

thumbnail:
	convert spectrum.eps -scale 300 full_thumbnail.jpg

# makes a huge JPEG file with decent resolution for printing
jpeg:
	gs -sDEVICE=jpeg -sOutputFile=spectrum.jpg -r300x300 -dGraphicsAlphaBits=4 spectrum.eps

jpeg600:
	gs -sDEVICE=jpeg -sOutputFile=spectrum.jpg -r600x600 -dGraphicsAlphaBits=4 spectrum.eps

# Split poster up into smaller printable sheets
# This function may not work too well with newer versions of "poster" program.
split:
	poster -v -c5% -s1 -mletter  spectrum.eps -ospectrum_pages.eps
	ps2pdf spectrum_pages.eps
	acroread spectrum_pages.pdf&
	zip spectrum_pages spectrum_pages.pdf

# Compile the C program that generates the numbers on the scales
numbers: numbers.c
	cc -lm -o numbers numbers.c
	./numbers > tex/numbers.tex &

# Compile the utility to convert frequencies to positions on chart
xpos: xpos.c
	cc -lm -o xpos xpos.c

# Compile the utility to convert a frequency range to positions on chart
kuband:
	echo "% Upload channels 1-16" > kbandTV.txt
	./xposrange.pl 14014.75e6 16 30.5e6 >> kbandTV.txt
	echo "% Download channels 17-32" >> kbandTV.txt
	./xposrange.pl 14027.75e6 16 30.5e6 >> kbandTV.txt 
	echo "% Download channels 1-16" >> kbandTV.txt
	./xposrange.pl 11714.75e6 16 30.5e6 >> kbandTV.txt
	echo "% Download channels 17-32" >> kbandTV.txt
	./xposrange.pl 11727.75e6 16 30.5e6 >> kbandTV.txt


# Compile the scales program
scale: scale.c
	cc -lm -o scale scale.c

# remove compiled temporary files
clean:
	rm *.dvi
	rm *.aux

# new update to website, modified for more recent changes.
new:
	cp spectrum_current.pdf /home/anthony/web/unihedron/projects/spectrum/downloads/
	sitecopy --update unihedron
	
# make a distributable file of the source code
dist:
	if test -d "$(NAME)-$(VERSION)"; then rm -rf $(NAME)-$(VERSION); fi
	if test -f "$(NAME)-$(VERSION).tar.gz"; then rm -f $(NAME)-$(VERSION).tar.gz; fi
	mkdir $(NAME)-$(VERSION)
	cp Makefile $(NAME)-$(VERSION)
	cp -R doc $(NAME)-$(VERSION)
	cp -R tex $(NAME)-$(VERSION)
	cp -R sizes $(NAME)-$(VERSION)
	cp -R sources $(NAME)-$(VERSION)
	cp -R pictures $(NAME)-$(VERSION)
	cp numbers.c $(NAME)-$(VERSION)
	cp xpos.c $(NAME)-$(VERSION)
	cp scale.c $(NAME)-$(VERSION)
	tar cvzf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	rm -rf $(NAME)-$(VERSION)
