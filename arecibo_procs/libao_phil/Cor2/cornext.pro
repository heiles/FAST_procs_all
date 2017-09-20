;+
;NAME:
;cornext - input and plot next rec from disc
;
;SYNTAX: cornext,lun,b,m=pltmsk
;  ARGS:
;           lun:    int assigned to open file.
;             b:    {corget}  data from last read
;KEYWORDS:
;             m:    which sbc to plot.. bitmask b0->b3 for brd1->4
;-
pro cornext,lun,b,m=pltmsk
;
on_error,1
if (n_elements(pltmsk) eq 0 ) then pltmsk=15
istat=corget(lun,b)
if istat ne 1 then return
corplot,b,m=pltmsk
return
end
