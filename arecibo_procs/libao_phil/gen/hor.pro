;+
;NAME:
;hor - set horizontal scale for plotting.
;SYNTAX: hor,hor1,hor2
;ARGS:
;   hor1: float min horizontal value
;   hor2: float max horizontal value.
;DESCRIPTION:
;   Load the !x.range system value with the min,max xrange to plot.
;To reset to auto scaling call hor with no args.
;SEE ALSO:
;   ver
;-
pro hor,xmin,xmax
    !x.style=!x.style or 1      
    if N_PARAMS() eq 0 then  begin
        !x.range=0
        return
    endif
    !x.range=[xmin,xmax]
    return
end
