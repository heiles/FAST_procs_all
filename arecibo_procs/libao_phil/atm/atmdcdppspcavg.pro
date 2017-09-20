;+
;NAME:
;atmdcdppspcavg - decode, compute pulse to pulse spc, and avg
;
;SYNTAX: nspc=atmdcdppspcavg(lun,secToAvg,spcLen,spcAvg,h=h,
;                   use2ndChn=use2ndChn,useMedian=useMedian,verb=verb,
;                   rectype=rectype,spctoavg=spctoavg)
;ARGS:
;     lun:int      lun for file to process. You should have alread opened it.
;secToAvg:float    seconds of data to average spectra over.
;  spclen:int      length  for spectra. This is the number of ipps 1
;                  spectra will cover.
;
;  KEYWORDS:
;use2ndchan:       if set then process the 2nd channel of data (fifo 2). The
;                  default is the first channel.
; useMedian:       if set then use the median when averaging the spectra.
;                  The default is the mean.
;      verb:       if set then print out when we start each block of spectra.
;   rectype: string Type of record to process. Use this if different kinds
;                  of records are present in the same file. The rectypes
;                  are defined in atmget(). For dregino profiles use
;                  rpwr88 or r52code. Be careful using this routine with
;                  datasets that are not contiguous in time. The spclen must
;                  divide evenly into the records for a given time block.
; spcToavg: int    if provided then ignore sectoavg, use this.. works
;                  better when ipp is not a submultiple of 1 sec
;
;RETURNS:
;      nspc:long   The number of spectra that have been averaged.
;spcAvg[spcLen,nhghts]:float  the averaged spectra. One for each decoded
;                  height.
;         h:{}     The header from the first record input.  
;
;DESCRIPTION:
;
;   Decode a number of ipps from atm rawdat, compute the pulse to pulse
;spectra, and then average these together. The user passes in the lun for
;the file to process, the seconds of data to process, and the length of the
;transform to use for the spectra.
;
;   The routine will process a block of spectra at a time. A block
;is defined as the number of spectra that will fit in 700 mb of memory
;(or the requested seconds of data if it is smaller).
;   For each block of spectra:
; 1. the data is input.
; 2. the mean value is removed from the complex voltages (dc is removed)
; 3. the data is decoded
; 4. the transform along the height direction is done for 
;    tne number of spc in the block
; 5. power is computeded
; 6. the spectral power is summed for each height (number of spectra in
;    the block).
;
;   If the usemedian keyword is set then step 6 uses the median value for
;each spectral height (over the number of spectra in the block). At the
;end the median from each block are averaged (weighted by the number of
;spectra in each median).
;
;   For a single channel of data (ch or dome), 349 heights, and 1 millisecond
;ipps, a block of spectra will be about 2 minutes of data. 
;
;EXAMPLES:
;   average 3 minutes of data:
;   file='/share/xserve0/aeron5bup/T2166/t2166_21mar2006.023'
;   openr,lun,file,/get_lun
;
;
;   secToAvg=60*3
;   spcLen  =512
;;
;;  this data set has:
;;  1. an ipp of 1040 usec, and 400 samples in the first rcv window.
;;  2. the codelen is 52. So there are 400-51=349 hghts after decoding.
;;  3. 3 minutes of data is 173077 ipps.  This is 339 512 length spectra
;;  4. 227 spectra fit in a block of 700Mb . The first block has 227 spectra,
;;     the second block has 112 spectra
;
;   
;   nspc=atmdcdppspcavg(lun,secToAvg,spcLen,spcAvgMed,/verb,/usemed)
;   help,spcavgmed,/st
;    SPCAVGMED       FLOAT     = Array[512, 349]
;
;;  make an image of the results
;
;   minval=5e-3
;   maxval=1.6e4
;   imgdisp,(spcavgMed > minval)<maxval
;
;WARNINGS:
; 1. If it hits an eof or a data set with a different length of data
;    that the one it is working with, then it will return with the
;    number of averaged spectra his has processed so far.
; 2. The median on the last block of spectra may be over a shorter length
;    than the previous sets. All median spectra are weighted by the 
;    the number of spectra used for the median.
; 3. If the data on disc comes from different programs (dregion spec
;    and clp), this routine will not average more than the data 
;    in 1 contiguous block of data. If you want to average for longer
;    just recall the program and do the average outside.
;
;SEE ALSO:
;   atmdcd
;
;-
function  atmdcdppspcavg,lun,sectoavg,spclen,spcAvg,h=h,use2ndchan=use2ndchan,$
                 verb=verb,usemedian=usemedian,rectype=rectype,spcToAvg=spcToAvg,$
				 search=search
;
; get a single rec for the header
;
    maxBytes=7e8
    point_lun,-lun,startpos
    istat=atmget(lun,d,/search,rectype=rectype)
    if istat le 0 then return,istat
    point_lun,lun,startpos
;
    h=d.h
    ipprec   =long(h.ri.ippsperbuf)
    codelen  =long(h.sps.codelenusec/h.sps.baudlen +.5)
    ndcdhghts=h.sps.rcvwin[0].numsamples - codelen + 1L
    ipp      =h.sps.ipp*1d-6
	if keyword_set(spcToAvg) then begin
		totIppsNeeded=spcToavg*spcLen
		if n_elements(secToavg) eq 0 then secToavg=0.
	endif else begin
    	totIppsNeeded= long(secToAvg/ipp + .5)
	endelse
    usecodeBarker=codelen eq 13
    usecode13    =codelen eq 13
    usecode88    =codelen eq 88
    usecode52    =codelen eq 52
;
;   make sure multiple of fft len,ipprec
;
    totSpcNeeded=totIppsNeeded/spclen
    if totSpcneeded*spclen ne totIppsNeeded then totSpcNeeded+=1L
;
;   break it in n spcblks if greater than 400 mb 
;   each spc. larger of (inbuf +vdcd) > (vdcd + complexspc)
;
    bytes1Spc=(n_tags(d[0],/length)*spclen/(ipprec*1.) + $
              ndcdhghts*spclen*8.) > $      ; decode voltages
              (ndcdhghts*spclen*8. + $      ; decode voltages
              spclen*ndcdhghts*8.)          ; spectra complex

    spcInBlk=long(maxBytes/bytes1spc)

    if spcInBlk lt 1  then spcInBlk=1L
    nblks=totSpcNeeded/spcInBlk
    spcLastblk=spcInBlk
    if nblks*spcInBlk lt totSpcNeeded then begin
        spcLastBlk=totSpcneeded - (nblks*spcInBlk)
        nblks+=1
    endif
    if nblks eq 1 then spcInblk=spcLastBlk
;

    ippsInBlk=spcInBlk*spclen
    recsInBlk=ippsInBlk/ipprec
    extraIpp=0L
    if recsInBlk*ipprec lt ippsInBlk then begin
        recsInBlk+=1
        extraIpp=recsInBlk*ippRec - ippsInBlk
    endif
;
;   allocate array to average spectra
;   
    spcAvg=fltarr(spclen,ndcdhghts) 
    spcCnt=0L                   ; how many we have accumulated in spcAvg
    if verb then print,'spcBlk:',spcInBlk,' totalSpc:',totSpcNeeded
    firstTime=1
    for iblk=0,nblks-1 do begin
;
;       if last time thru may have fewer spectra
;
        spcThisBlk=(iblk eq (nblks-1)) ? spcLastBlk:spcInBlk
        if verb then begin
          print,'Starting block:',iblk,' spcThisBlk:',spcThisBlk
        endif
        ippsInBlk=spcThisBlk*spclen
        recsInBlk=ippsInBlk/ipprec
        extraIpp=0L
        if recsInBlk*ipprec lt ippsInBlk then begin
            recsInBlk+=1
            extraIpp=recsInBlk*ippRec - ippsInBlk
        endif
;
;      read the data
;
        istat=atmget(lun,d,nrecs=recsInBlk,/search,/contiguous,$
                      rectype=rectype)
;
;       if eof,error jump out
        if istat le 0 then break
;
;       if fewer recs then requested, recompute
;       number of spectra we can do
;
        if istat gt 1 then begin
            recsInBlk=n_elements(d)
            ippsInBlk=recsInBlk* ipprec
            spcThisBlk=(ippsInBlk)/spclen
            if spcThisBlk eq 0 then break
            extraIpp=ippsInBlk - spcThisBlk*spcLen
        endif
;
;    remove dc
;
        if keyword_set(use2ndchan) then begin
            dc=mean(d.d2)
            d.d2-=dc
        endif else begin
            dc=mean(d.d1)
            d.d1-=dc
        endelse

;
;       decode the data
;   
		if (not firsttime) and (n_elements(code) eq 0) then begin
			print,"not firsttime and no code"
			stop
		endif
		useBarker=usecode13 or useCodeBarker
        nipps=atmdcd(d,code,vdcd,firsttime=firstTime,$
                     use2ndchan=use2ndchan,dcdh=dcdh,$
                     codelen88 =usecode88,$
                     codelen52 =usecode52,$
                     barkercode=usebarker)
        firstTime=0
        d=''
;
;       if ipprec*nrec not a multiple of spclen then throw out
;       ipps at the end 
;       then make 3d array nhght,spclen,spcInBlk
;       then tranpose to spclen,spcinblk,nhght
;
        if extraIpp gt 0 then begin
            n=n_elements(vdcd)
			nkeep=ndcdhghts*spclen*spcthisblk
            vdcd= transpose(reform((reform(temporary(vdcd)))[0:nkeep-1],$
                          ndcdhghts,spclen,spcThisBlk),[1,2,0])
        endif else begin
            vdcd=transpose(reform(temporary(vdcd),ndcdhghts,spclen,spcThisBlk),$
                        [1,2,0])
        endelse
        if keyword_set(usemedian) then begin
            spcAvg+= median(abs(fft(temporary(vdcd),dim=1))^2,dim=2)*spcThisBlk
        endif else begin
            spcAvg+= total(abs(fft(temporary(vdcd),dim=1))^2,2)
        endelse
        spcCnt+=spcThisBlk
    endfor  
;
;   now divide by number of blocks
;   
    if spcCnt eq 0 then begin
        spcavg=0.
    endif else begin    
        spcAvg/=spcCnt
;
;       rotate spcAvg
;   
        spcAvg=shift(spcAvg,spcLen/2,0)
    endelse
    return,spcCnt
end
