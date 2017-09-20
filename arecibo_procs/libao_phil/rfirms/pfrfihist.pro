;+
;NAME:
;pfrfihist - compute histogram for all files in filelist
;SYNTAX: numscans=pfrfihist(fname,freqmin,freqmax,histinfo,histAr,$
;                 rcvList=rcvList,edgefr=edgefr,rejectfr=rejectfr,
;             sigma=sigma,binstep=binstep,verbose=verbose,wait=wait,han=han,$
;			   alfaBadBms=alfaBadBms)
;ARGS:
;       fname:  string . file containing list of filenames to process
;    freqmin :  float  . min frequency to histogram in Mhz.
;    freqmax :  float  . max frequency to histogram in Mhz.
;
;RETURNS:
;    histInfo       : {rfihistinfo} holds the histogram parameters used
;    histart[nchn,3]:long histogram of [*,tot=0,rfi=1,reject=2]
;           
;
;KEYWORDS:   
;         han:      if set then processed data was hanning smoothed.
;   rcvList[]: int  if supplied then limit data to these receiver numbers.
;      edgefr: float. fraction of each band that is discarded on each edge
;                     (do to filter rolloff). default: .05
;    rejectfr: float. If the fraction of bad channels in a single rms 
;                     bandpass exceeds this fraction, then rms bandpass will
;                     not be included in either histogram. default=.5
;       sigma: float. The number of sigmas above that defines an rfi event.
;     binstep: float. The binsize in mhz. default: .1 Mhz.
;                    if not provided then log to default log file
;alfaBadBms[2,8]: int bad beams for alfa.. [pol, bm] 
;                    8 beams since last is duplicated in wapps.
;                    putting a 1 in a location will ignore this
;                    pol,beam in the histogram. use for bad beams..
;
;DESCRIPTION:
;   This routine will create a histogram of rfi versus frequency. fname 
;is an ascii file that contains files to process. Each of these files contains
;rms spectra that have been processed by corrms (usually via pfrms()). 
;An rms spectra has had the rms/Mean computed for each frequency channel
;in a scan (typically sampled at 1 or 6 seconds).
;Rfi is defined as any rms greater than a default value (set by the sigma
;keyword). 
;
;A histogram of the total number of counts, and the total number of rfi's
;found is returned. The histogram bins are centered at the start,end bins.
;If the data resolution is greater than the histogram resolution, then 
;all of these data channels map into 1 total count. Any (and all)data channels
;in the group will count as 1 rfi count.
;
;The expected sigma is computed using the time, channel bandwidth, double 
;nyquist, and level sampling. The bins are assumed to be rectangular.
;
;A fraction of the bandpass is discarded at each edge because of filter
;rolloff. Bandpassed will not be included if the fraction of bad channels
;exceeds a predetermined value. 
;
;-
;history:
;09feb02 change edge fract from .05 (1.25Mhz) to .04 (1mhz). this matches
;		 the overlap taken by x111 data of 23 mhz between centers
;05mar05 added noflip keyword when reading rms data. This data is never
;        flipped. Trouble occured when fits data converted to cor data
;        and then the rms was written back out.
;
function   pfrfihist,fname,freqmin,freqmax,histinfo,histar,$
                 rcvList=rcvList,edgefr=edgefr,rejectfr=rejectfr,sigma=sigma,$
                 binstep=binstep,wait=wait,verbose=verbose,han=han,$
				 alfaBadBms=alfaBadBms

    if n_elements(binstep)  eq 0 then binstep =.1
    if n_elements(rejectfr) eq 0 then rejectfr=.5
;
    if n_elements(edgefr)   eq 0 then edgefr  =.04;
    if n_elements(sigma)    eq 0 then sigma=2.
    if not keyword_set(verbose) then verbose=0
    if not keyword_set(wait)    then wait   =0
	if n_elements(alfaBadBms) ne 16 then alfaBadBms=intarr(2,8)
    nrcvlist=n_elements(rcvlist)
    openr,lunin,fname,error=openerr,/get_lun
    if openerr ne 0 then begin
        printf,-2,!err_string
        return,0
    endif
;
;   fill in the hist info structure
;
    histinfo={rfihistinfo}
    histinfo.frqSt =freqmin
    histinfo.frqStp=binStep
    l=long((freqmax-freqmin)/binstep + .5)
    histinfo.frqEnd=histinfo.frqSt + binStep*(l)
    histinfo.totchn=l+1         ;since they are center of bins
    histinfo.edgeFrac=edgeFr
    histinfo.rejectFrac=rejectFr
    histinfo.sigmatoClip=sigma
    on_ioerror,ioerr
    filesdone=0L
    finput=' '
    lundat=-1
    histar=lonarr(histinfo.totchn,3)
    for i=0L,9999 do begin
        readf,lunin,finput
        finput=strtrim(finput,2)
        if strpos(finput,';') ne 0 then begin
            print,'processing file: ',finput
            openr,lundat,finput,error=openerr,/get_lun
            if openerr ne 0 then begin
                printf,-2,!err_string
            endif else begin
                repeat begin
                    istat=corget(lundat,b,/noscale,/noflip)
                    if istat eq 1 then begin
;                       corplot,b
                        rcvrok=1
                        if (nrcvlist gt 0 ) then begin 
                            rfnum=iflohrfnum(b.b1.h.iflo)
                            ind=where(rfnum eq rcvlist,rcvrok)
                        endif
                        if (rcvrok gt 0) then begin $
;
;						If alfa include bad beams..
;
							badSbc=(iflohrfnum(b.b1.h.iflo) eq 17)?$
									alfaBadBms:lonarr(2,8)
                            rfihistscan,b,histinfo,histar,han=han,$
                            verbose=verbose,wait=wait,badSbc=badSbc
						endif
                    endif
                end until istat ne 1
                if istat ne 0 then begin
                    printf,-2,'file:',finput,!err_string
                endif
                free_lun,lundat
                filesdone=filesdone+1
            endelse
        endif
    endfor
ioerr: 
    free_lun,lunin
    return,filesdone
end
