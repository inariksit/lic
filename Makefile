tex = lic

all: pdf clean

# Build the PDF
pdf:
	xelatex $(tex)
	bibtex $(tex)
	xelatex $(tex)
	xelatex $(tex)

p:
	xelatex $(tex)

clean:
	rm -f *.zip *.aux *.log *.out *.blg *.bbl *.toc *.mtc *.maf *.mtc[0-9] chapters/*.aux