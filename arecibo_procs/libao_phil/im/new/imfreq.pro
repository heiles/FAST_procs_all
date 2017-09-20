+
;NAME:
;imfreq - select a frequency band to use for sequential plotting.
;SYNTAX:  imfreq,d,frq
;ARGS:
;   d:{iminpday} data input via iminpday.
; frq: float     frequency in Mhz for center of band to plot (see imfrqlist()
;				 for the list of frequencies). -1 will reset to plot
; 			     all of the frequency bands.
;
;DESCRIPTION:
;   Select a frequency band for sequential plotting. The imn() routine
;will step thru only this frequency band when called (by default it
;steps through all of the frequency bands).
;-
pro imfreq,d,freq
;
    if ( freq ge 0.) then begin
        i=where((d.frql eq freq),count)
        if (count eq 0) then begin
            print,'valid frequencies:',d.frql
            return
        end
    end
    d.cfrq=float(freq)
    return
end
