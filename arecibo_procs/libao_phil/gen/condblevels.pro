;+
;NAME:
;condblevels - compute db contouring levels for a map
;SYNTAX: levels=condblevels(map,nlevels,dbstep,maxval)       
;ARGS:
;  map[m,n]: float  data to to compute levels for.
; nlevels  : int    number of levels requested
;    dbstep; float  dbstep between levels
;RETURNS: 
;levels[nlevels]: float holding the values to use to mark the contours
;maxval         : float the maximum value in map. The contours are relative
;                 to this value.
;DESCRIPTION:
;   Compute nlevels space dbstep apart from the maximum value in map.
;-
function condblevels,y,nlevels,dbstep,maxval
    maxval=max(y)
    levels= maxval*10^(-.1*findgen(nlevels)*dbstep)
    return, levels[sort(levels)]
    end

