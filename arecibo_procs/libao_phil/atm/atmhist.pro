;+
;NAME:
;atmhist - compute histogram of sampled voltages
;SYNTAX: npnts=atmhist(fname,histar,maxtm=maxtm,maxrec=maxrec,maxsmp=maxsmp,$
;                       verb=verb,d=d)
;ARGS:
;   fname:  string  filename to process (must include complete path)
;histar[4096,n]: long   contains the returned histograms of the 
;                   voltage samples.
;                   n=2 if 1 channel is used,
;                   n=4 if 2 channels are used (ch and dome)
;KEYWORDS:
;   maxtm:  float   limit histogram to maxtm seconds of data
;                   If nothing specified then maxtm is defaulted to 100 secs.
;  maxrec:  float   limit to maxrec records of data
;  maxsmp:  float   limit to maxsmp samples of data.
;  verb  :          if set then plot the progress in 10% steps..
;                   outputing the ipps and samples read so far.
;
;RETURNS:
;   npts: double    number of counts is a single histogram.
;histar[4096,n] long histogram of the voltages. 
;   d[100]:         if supplied then return the first 100 records read
;                   in d
;
;DESCRIPTION:
;   Compute a histogram of the voltages sampled from an aeronomy rawdata
;file. Any transmitter samples are discarded. Any cal samples are included.
;The number of samples read depends on the keywords maxtm, maxrec, or
;maxsmp. If none of these are set then 100 seconds of data are used.
;
;   The routine will read 100 records at a time computing a cumulative
;histogram for the sampled values. The assumptions made by the 
;program are:
;
;1. the data is rawdat voltages.
;
;2. All of the records read are the same as the first record of the
;   file.
;
;3. The ri is set to 12 bit sampling. Actually this is not a real
;   limitation, just that the returned values will only cover part of the
;   4096 length histogram.
;
;4. The counts are stored as longs so don't have more than 2^31-1
;   counts in any bin.
;
;5. The routine alway reads a multiple of 100 recs so you may get a little
;   more data than you asked for.
;
;   The returned data is in histar[4096,n] where:
;
;    0:4095 maps into digitizer levels -2048 to +2047
;    n    is:
;       for 1 channel  (dome or ch)  n=2
;       for 2 channels (dome and ch) n=4
;   
;   For any pair
;    histar[*,0] is the digitizer sampling the real part of the complex num
;                q digitizer (right bnc of the pair)
;    histar[*,1] is the digitizer sampling the img  part of the complex num
;                i digitizer (left bnc of the pair)
;
;EXAMPLES:
;   file='/share/aeron5/t2163_19mar2006.003'
;   npts=atmhist(file,histar,maxtm=200,/verb)
;
;   x=fingen(4096) - 2048
;   plot,x,histar[*,0]
;   oplot,x,histar[*,1],color=colph[2]
;- 
;22mar06:
;
;BUG:
; idl version 6.1
;   h1=histogram(i1,....) 
;   h2=histogram(i2,....) 
;   h=histogram(i2,....input=h1)  always returns h1  instead of h1+h2
;
function atmhist,fname,histAr,maxTm=maxTm,maxRec=maxRec,maxSmp=maxSmp ,$
            verb=verb,d=dl
    
    if n_elements(maxtm)  eq 0 then maxtm =0.
    if n_elements(maxrec) eq 0 then maxrec=0l
    if n_elements(maxSmp) eq 0 then maxSmp=0L
;
;   try opening the file
;
    lun=-1
    openr,lun,fname,/get_lun,err=err
    if err ne 0 then begin
        print,'Error opening :',fname,!err_state.msg
        return,-1
    endif
;
; histogram setup 
;
    maxv=2047L
    minv=-2048L
;
    recPerRd=100    
    done=0
    firsttime=1
    maxRd=0l
    totCnts=0D
    totRds=0L
    while (not done) do begin
        istat=atmget(lun,d,/search,nrec=recPerRd) &$
        if istat ne 1 then goto,done
        if firsttime then begin
            ntx      =d[0].h.sps.SMPINTXPULSE &$
            spipp    =d[0].h.ri.SMPPAIRIPP &$
            spipprcv = spipp - ntx
            ipprec   =d[0].h.ri.IPPSPERBUF &$
            ippRd    =recPerRd*ipprec
            ipp      =d[0].h.ri.ipp
            smpTot   =spipp*ippRd &$
            smpTotRcv=smpTot - ntx*ippRd
            nfifo=(d[0].h.ri.fifonum eq 12) ?  2: 1 &$
            histar=(nfifo eq 2)?lonarr(4096,4):lonarr(4096,2)
            if maxRec ne 0L  then begin
                maxRd=maxRec/(recPerRd) + 1L
            endif
            if maxSmp ne 0L  then begin
                maxRd=maxSmp/(smpTotRcv) + 1L
            endif
            if (maxTm ne 0.) or (maxRd eq 0)  then begin
                maxTm = (maxTm eq 0.)?100.:maxTm
                maxRd=long(maxTm/(ipp*1e-6*ippRd) + .5)
            endif
            firsttime=0L
            if arg_present(dl) then dl=d
        endif
        if ntx gt 0 then begin &$
          i1=(reform(round(    float(d.d1)) ,spipp,ipprd))[ntx:*,*]&$
          q1=(reform(round(imaginary(d.d1)) ,spipp,ippRd))[ntx:*,*]&$
          if nfifo eq 2 then begin &$
            i2=(reform(round(    float(d.d2)),spipp,ippRd))[ntx:*,*]&$
            q2=(reform(round(imaginary(d.d2)),spipp,ippRd))[ntx:*,*]&$
          endif &$
        endif else begin &$
          i1=reform(round(    float(d.d1))     ,spipp,smpTot/spipp) &$
          q1=reform(round(imaginary(d.d1)),spipp,ippRd) &$
          if nfifo eq 2 then begin &$
            i2=reform(round(    float(d.d2)),spipp,ippRd) &$
            q2=reform(round(imaginary(d.d2)),spipp,ippRd) &$
          endif &$
        endelse &$
;       print,totCnts,total(histar[*,0])
        histAr[*,0]+=histogram(i1,binsize=1,max=maxv,min=minv)  &$
        histAr[*,1]+=histogram(q1,binsize=1,max=maxv,min=minv)  &$
        if nfifo eq 2 then begin &$
            histAr[*,2]+=histogram(i2,binsize=1,max=maxv,min=minv)  &$
            histAr[*,3]+=histogram(q2,binsize=1,max=maxv,min=minv)  &$
        endif
        totCnts+=smpTotRcv &$
        totRds+=1L
        done=totRds ge maxRd
        if keyword_set(verb) then begin
            i=long(maxRd*.1)
            if (totRds mod i) eq 1 then begin
                print,totRds*ippRd,totCnts
            endif
        endif
    endwhile
done:
    if lun ne -1 then free_lun,lun
    return,totCnts
end
