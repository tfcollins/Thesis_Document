all: thesis_temp.pdf

thesis_temp.pdf: wilab_template.dvi
	dvipdfm wilab_template

thesis_temp.dvi: thesis_temp.tex my.bib
	latex thesis_temp
	bibtex my
	latex thesis_temp
	latex thesis_temp

announcement.dvi: announcement.tex
	latex announcement.tex

announcement.pdf: announcement.dvi
	dvipdfm announcement

#rm *.blg *.aux *.log *.lot *.bbl *.toc *.lof
