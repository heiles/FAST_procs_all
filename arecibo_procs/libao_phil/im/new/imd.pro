+
;NAME:
;imd - plot the specified record of the day.
;
;SYNTAX:  imd,d,recnum
;
;ARGS:
;   d     :{iminpday} data input via iminpday.
;   recnum: long      record number of day to plot (count from 1).
;
;DESCRIPTION:
;   Plots the data for record recnum for the given day. You must first
;input the data using iminpday().
;
;SEE ALSO:
;	iminpday,imn,imc,imfreq
;-
pro imd,d,recnum
    if ((recnum lt 1) or ( recnum gt d.nrecs)) then begin
        print,'err:recnum out of range:1 ..',d.nrecs
        retall
    end
    d.crec=recnum
    implot,d.r[recnum-1]
    return;
end
