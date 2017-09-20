;+
;NAME:
;imc   - replot the current current
;SYNTAX: imc,d
;
;ARGS:
;   d:{iminpday} data input from iminpday.
;
;RETURNS:
;
;KEYWORDS:
;
;DESCRIPTION:
;   Replot the current record. This is part of the sequential plotting
;package. 
;
;SEE ALSO:
;	imd,imn,imfreq
;-
pro imc,d
    if (d.crec lt 1) then d.crec = 1 else $
    if (d.crec gt d.nrecs) then d.crec=d.nrecs
    implot,d.r[d.crec-1]
    return;
end
