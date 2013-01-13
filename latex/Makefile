all: thesis.pdf

#remove anything I may not want...
clean :
	@rm *.aux *.bbl *.toc *.log *.pdf *.blg *.lof *.lot 

thesis.pdf: thesis.tex mybib.bib
	pdflatex thesis
	bibtex thesis
	pdflatex thesis
	pdflatex thesis
	pdflatex thesis

#rm *.blg *.aux *.log *.lot *.bbl *.toc *.lof
