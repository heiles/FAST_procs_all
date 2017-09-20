;+
;NAME:
;x111select - select a subset of scans to process
;SYNTAX: n=x111select(yymmdd1,yymmdd2,slar,slfilear,rcv=rcv,frqrange=frqrange)
;ARGS:
;	yymmdd1: long	first date to use
;   yymmdd2: long   last date to use
;KEYWORDS:
;     rcv:  long	limit to reciever number (1.. 17)
;frqrange[2]:float  min, max frequency to look for
;RETURNS:
;       n: long	    number of scans found
;      slar[n]: {slcor} array of struct having info
;  slfilear[m]: {slfile} filename array
;
;-
function x111select,yymmdd1,yymmdd2,slar,slfilear,rcv=rcv,frqrange=frqrange
;
; 
	nscans=arch_gettbl(yymmdd1,yymmdd2,slar,slfilear,rcvnum=rcv,freq=frqrange,$
                       proj=projid,/cor)
;
;	limit to x111 with 60 recs and cal on/off.. 
;   this gets rid of x101 runs that have left the x111 projid 
; 
	if nscans eq 0 then return,nscans
	pattype=7                   ; x111 auto with cals
    nsets=corfindpat(slar,indar,pattype=pattype)
	if (nsets*3L lt nscans) then begin
		ii=lonarr(3,nsets)
		ii[0,*]=indar
	    ii[1,*]=indar+1
        ii[2,*]=indar+2
		slar=slar[ii]
		nscans=n_elements(slar)
	endif
;
   return,nscans
end
