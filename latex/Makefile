all: thesis.pdf

#remove anything I may not want...
clean :
	@rm *.aux *.bbl *.toc *.log *.pdf *.blg *.lof *.lot 

thesis.pdf: thesis.tex mybib.bib
	pdflatex -aux-directory=build -output-directory=build thesis 
	bibtex thesis
	pdflatex -aux-directory=build -output-directory=build thesis
	pdflatex -aux-directory=build -output-directory=build thesis
	pdflatex -aux-directory=build -output-directory=build thesis

local: thesis.tex mybib.bib
	latex thesis.tex
	bibtex thesis
	latex thesis.tex 
	dvips -Ppdf thesis.dvi
	ps2pdf thesis.ps

#rm *.blg *.aux *.log *.lot *.bbl *.toc *.lof
