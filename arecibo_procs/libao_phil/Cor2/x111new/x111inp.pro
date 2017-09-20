;+
;NAME:
;x111inp - input 1 or more data,cal sets of data.
;SYNTAX: x111inp(yymmdd1,yymmdd2,freqReq,bret,rcv=rcv,han=han,$
;                slar=slar,slfilear=slfilear,indonly=indonly,verbose=verbose)
;ARGS:
;	yymmdd1: long	first date to use
;   yymmdd2: long   last date to use
;   freqReq: float  freq in Mhz to select
;KEYWORDS:
;     rcv:  long	limit to reciever number (1.. 17) (only needed if 
;                   more than 1 rcvr measures this freq (eg sbw,sbn)
;     han:          if set then hanning smooth the data on input.
;   indonly:        if set then search the database for the scans.
;                   return in slar the first scan of each set (the data scan).
;   verbose:        if set then print date/scan of each set found
;RETURNS:
;       n: long	    number of sets found
;    bret[n]:{}     structure containing the data found
;    slar[3,n]: {slcor} summary info for each scan found (data and cals)
;  slfilear[m]: {slfile} filename array. slar.fileindex indexes into this array.
;
;-
function x111inp,yymmdd1,yymmdd2,freqReq,bret,verbose=verbose,han=han,$
			slar=slar,slfilear=slfilear,rcv=rcv,maxSets=maxSets,indonly=indonly
;
; 
          
    if n_elements(maxSets) eq 0 then maxSets=100
    verboseL=keyword_set(verbose)?1:0
	recsData=60
    recsCal=2
    recsPerSet=recsData+recsCal
	projid='x111'
    recsScan=60L
	nscans=arch_gettbl(yymmdd1,yymmdd2,slar,slfilear,rcvnum=rcv,freq=freqreq,$
                       proj=projid,/cor)
	if nscans eq 0 then return ,0
	pattype=7					; x111 auto with cals
    nsets=corfindpat(slar,indar,pattype=pattype)
;
;   check to see if we have two receivers.. if so, use the one with the
;   lowest receiver number
;
	if not keyword_set(rcv) then begin
       rcvl=slar[indar].rcvnum
       urcvl=rcvl[uniq(rcvl,sort(rcvl))]
       if n_elements(urcvl) gt 1 then begin
          ii=where(slar[indar].rcvnum eq urcvl[0],nsets)
          if nsets eq 0 then return ,nsets
          indar=indar[ii]
       endif
    endif
;
	if keyword_set(indonly) then begin
       slar=slar[indar]
       return,nsets
	endif

;
;   limit to max number of sets
;
	nsets=(nsets < maxSets)
;
;   indar has the start of each set
;
    ind=lonarr(3)				; data, calon,caloff
    firstTime=1
    itotSets=0L
    indgood=lonarr(n_elements(slar))
    alldat=2					; code for getdata to return all hdrs,recs
	for iset=0,nsets-1 do begin
		ind[0]=indar[iset]
		ind[1]=ind[0]+1
		ind[2]=ind[0]+2
        n=arch_getdata(slar,slfilear,ind,b,type=alldat,han=han)
        if verboseL then begin
           yr=b[0].b1.h.std.date/1000L
           dayno=b[0].b1.h.std.date mod 1000L
           dm=daynotodm(dayno,yr)
           yymmdd=(yr mod 100L)*10000L + dm[1]*100L+dm[0]
           dmy=yymmddtodmy(yymmdd)
           lab=string(format=$
'("iset:",i3," date:",a," scan:",i9," nrecs:",i3)',iset,dmy,$
                  b[0].b1.h.std.scannumber,n)
			print,lab
        endif
        if n ne recsPerSet then continue
        indgood[ind]=1
        if firstTime then begin
;
;		figure out the brd to keep
;
			nbrds=b[0].b1.h.cor.numbrdsused
            if nbrds gt 1 then begin
            	cfrAr=fltarr(nbrds)
            	for i=0,nbrds-1 do cfrAr[i]=corhcfrtop(b[0].(i).h)
           	    dif=abs(cfrAr - freqReq)
                aa=min(dif,ibrdToUse)
                brdToUse=ibrdToUse+1
                bb=corsubset(b[0],brdToUse)
            endif else begin
                brdTouse=1
                bb=b[0]
		    endelse
            bdata=replicate(bb,recsData,nsets)
            bcal =replicate(bb,recsCal,nsets)
            firstTime=0 
         endif
		 if nbrds eq 1 then begin
         	bdata[*,itotSets]=b[0:recsData-1]
            bCal[*,itotSets]=b[recsData:recsPerSet-1]
		 endif else begin
         	bdata[*,itotSets]=corsubset(b[0:recsData-1],brdToUse)
            bCal[*,itotSets] =corsubset(b[recsData:recsPerSet-1],brdToUse)
		 endelse
	     itotSets++
	endfor
	if itotSets ne nsets then begin
		bata=bdata[*,0:itotSets-1L]
		bcal=bcal[*,0:itotSets-1L]
	endif
;
;   now create struct to return
;
	bret= {$
            nsets : itotSets,$
            bcal  : temporary(bcal),$
            bdat  : temporary(bdata)$
		  }
	if arg_present(slar) then begin
		ii=where(indgood eq 1,count)
        if count gt 0 then slar=reform(slar[ii],3,itotSets)
	endif
	return,itotSets
end
