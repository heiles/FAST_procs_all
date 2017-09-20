.run skyabscmp
.run skyabscumall
pscol,file='lbncal.ps',/full
.run skyabsplot
hardcopy
x
;
pscol,file='lbnspec.ps',/full
.run skyabsplspec
hardcopy
x
;
pscol,file='lbndiag.ps',/full
.run skyabsdiag
hardcopy
x
