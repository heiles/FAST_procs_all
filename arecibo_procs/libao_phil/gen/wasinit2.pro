; 10jan08 wasinit,wasinit2, wasinit2n are now all the same file
;         They are the uptodate version to use.
;         the old header version (pre 2004) is now in wasinitold.pro
;         (i've left the duplicate names  wasinit2, wasinit2n so old
;           code doesn't break)
@corinit
addpath,'was2'
; get updated version
.compile corhquery
@was.h
;
; hold the luns as we open descriptors, 
; this allows us to close all the luns at once if we want
;
common wascom,wasnluns,waslunar
    wasnluns=0L
    waslunar=intarr(100)

forward_function wasalignrec,wasfnamemk,wasfnamepars,wasftochdr,$
        wasget,washdr,wasopen,waspos,wasprojfiles,waspwr
