;+
;NAME:
;ver - set vertical scale for plotting.
;SYNTAX: ver,ver1,ver2
;ARGS:
;   ver1: float min vertical value
;   ver2: float max vertical value.
;DESCRIPTION:
;   Load the !y.range system value with the min,max yrange to plot.
;To reset to auto scaling call ver with no args.
;SEE ALSO:
;   hor
;-

;------------------------------------------------------------------------------
;ver - ymin, ymax  set min,max plotting range
;
pro ver,ymin,ymax
    !y.style=!y.style or 1
    if N_PARAMS() eq 0 then  begin
        !y.range=0
        return
    endif
    !y.range=[ymin,ymax]
    return
end
