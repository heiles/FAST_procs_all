;+
;NAME:
;mmcmpsefd - compute sefd for each entry in mm structure
;SYNTAX: sefd=mmcmpsefd(mm)
;ARGS:  
;     mm[n]: {mueller} mueller structure from mmgetarchive
;RETURNS:
;   sefd[n]: float  the Sefd  System equivalent flux density
;DESCRIPTION:
;   Compute the SEFD for each entry in the mm structure.
;-
function mmcmpsefd,mm
;
    return,mm.fit.tsys*mm.srcflux/mm.fit.tsrc
end
