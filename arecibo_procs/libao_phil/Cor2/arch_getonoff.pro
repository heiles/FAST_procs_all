;+
;NAME:
;arch_getonoff - get on/off -1 data from archive
;SYNTAX: nfound=arch_getonoff(slAr,slfileAr,indar,bout,infoAr,$
;                   incompat=incompat,han=han,scljy=scljy,verbose=verbose)
;ARGS: 
;      slAr[n]   : {sl} or {corsl}  returned by arch_gettbl
;    slFileAr[m] : {slInd} returned by arch_gettbl
;     indar[]    : long    indices into slar for scans to return
;KEYWORDS: (for corposonoff)
;     han:  if set then hanning smooth
;   scljy:  if set then scale to jy using gain curve for date of scan.
;           if not set then return in Kelvins.  
;   verbose:if set then call correcinfo for each scan we process
;RETURNS:
;nfound     : long number of on/off-1 returned in bout
;infoAr[2,n]: long info on each on/off -1 found. Values are:
;               info[0,n] status of the returned on/off's
;                1 - on/off -1 returned as requested.
;                2 - on/off -1 but only the off was in ind[]. This could 
;                    occur if you asked for all the scans within the radius
;                    of some ra/dec and the off fell within the radius
;                    but not the on. You might then look for a negative
;                    going galaxy in the on/off-1.
;               <0- no cal was found so the units are Tsys.
;                   returnes -1 or -2
;               info[1,n] this is the index into indar[] where this on/off
;                    was found (could be the on or the off).
;  bout[n] :    on/off-1 scaled to jy, K, or tsys (see info[]). There is
;                    one elemetn for each on/off pair found
;incompat[p] long indices in indAr that were not returned because the
;                 datatype differs from that of the first on/off pair.
;                 Since bout[] is an array, each element must have the same
;                 format (eg. number of boards, lags/sbc, etc..).
;
;DESCRIPTION:
;   After using arch_gettbl() and possibly where(), call this routine
;to process all of the on,off position switch records included in the
;subset slar[ind]. It will search for all of the on or offs in ind[] and
;process them via corposonoff(). If only an ON or an OFF is found in ind[]
;it will still try to process the pair. By default it will use the cal
;to return the data in kelvins. The /scljy will return the data in janskies.
;If no cal scan is found, then the data is returned in units of Tsys.
;   The infoar[2,*] returns information on the returned data. The first
;index tells the format of the data, the second index is the ptr into
;slar where the onPos was found.
;
;EXAMPLES
;
;;get all data for jan02->apr02 cband
;   nscans=arch_gettbl(020101,020430,slAr,slFileAr,rcv=9)
;; select all the on/off pairs
;   pattype= 1                      ; on/off position with cal on,off
;   nfound=corfindpat(slar,indar,pattype=pattype
;   n=arch_getonoff(slar,slfilear,indar,b,type=3,incompat=incompat)
;
;NOTE:
;    The routine expects to find the on,off, and cals in the slar. You should
;pass the entire slar with indar as the thing that does the subsetting. 
;Don't pass a subset of slar into this routine: eg..
;
;   arch_gettbl(010101,011230,slar,slfilear,rcv=6)
;   ra =131215.1 
;   dec=101112.
;   dist=cmpcordist(ra,dec,slar=slar)
;;  find all points within 30 arcminutes of ra,dec from projid a1199
;;  ..wrong.. 
;   ind=where(dist[2,*] lt 30.,count)
;   slarn=slar[ind]
;   ind=where(slarn.projid eq 'a1199',count)  
;     npts=arch_getonoff(slarn,slfilear,ind,/scljy)
;;  .. correct:
;   ind=where((dist[2,*] lt 30.) and (slar.projid eq 'a1199'),count)
;   npts=arch_getonoff(slar,slfilear,ind,/scljy)
;-
function arch_getonoff,slAr,slfilear,indar,bout,infoAr,incompat=incompat,$
                       han=han,scljy=scljy,verbose=verbose
;
;   some constants
;
    poson =3
    posoff=4
    calon=1
    caloff=2
;           1 - 1 pol 2- 2 pol, 4 complex or stokes,0
;                 0,1,2,3,4,5,6,7,8,9,10]
    lagConfNsbc=[1,1,2,1,4,2,1,1,2,2,4] ; number sbc each lag config
;
    ii=where((slar[indar].rectype eq 3) or (slar[indar].rectype eq 4),maxbout)
    if maxbout eq 0 then begin
       infoar=0
       b=0
       return0
    endif
    if not keyword_set(scljy) then scljy=0
    if not keyword_set(verbose) then verbose=0
    gotonoff=1
    gotonoffcal=2
    curFileInd=-1L
    lun=-1
    n_indar=n_elements(indar)
    n_sl =n_elements(slar)
    n_bout=0L                               ; number we've computed so far
    incompat=lonarr(n_indar)-1
    n_incompat=0
    infoAr=lonarr(2,n_indar)
        
;
    curfileInd=-1
    lun=-1
;    on_error,1
    i_indar=0L                      ;index into indar[]
    while 1 do begin
;
        if i_indar ge n_indar then goto,done
        iskip=1                 ; by def when done skip to next i_indar
        rec_incompat=1
        gotonoff=0
        gotcal=0
;
;       try to figure what type of scan we are looking at.
;   
        i_sl=indar[i_indar]
;       print,'ind:',i_indar,' i_sl',i_sl,' rec:',slar[i_sl].rectype
        case slar[i_sl].rectype of
;
;           onoff posswitch
;
            poson: begin
;
;             off follows with same number of records??
;
                if (i_sl+1) ge n_sl then goto,done  ; no posoff
                if (slar[i_sl+1].rectype ne  posOff) or  $
                   (slar[i_sl+1].numrecs ne slar[i_sl].numrecs) then goto,skip
                if ((i_indar+1) lt n_indar) then begin
                    iskip=(slar[i_sl+1].scan eq slar[indar[i_indar+1]].scan)?$
                            2:iskip
                endif
                gotonoff=1
                i_sltouse=i_sl
;
;               cal onoff follows ??
;
                if (i_sl+3) lt n_sl then begin
                    gotcal=( slar[i_sl+2].rectype eq calon) and $
                           ( slar[i_sl+3].rectype eq caloff)
                endif
                end 

            posoff: begin
                if (i_sl gt 0) then begin
                    if (slar[i_sl-1].rectype ne  posOn) or $
                   (slar[i_sl-1].numrecs ne slar[i_sl].numrecs) then goto,skip
                    gotonoff=1
                    i_sltouse=i_sl-1
                    if (i_sl + 2) lt n_sl then begin
                        gotcal=( slar[i_sl+1].rectype eq calon) and $
                               ( slar[i_sl+2].rectype eq caloff)
                    endif
                endif
                end 
                
            else : goto,skip
        endcase
;
;       got on/off.. process
;
        if gotonoff then begin
;
;           if not the first time see if the data types differs..
;
            if n_bout ne 0 then begin
                i_sl0=infoar[1,0]
                if slar[i_sl0].numfrq ne slar[i_sltouse].numfrq then begin
                   goto,incompat
                endif
;
                if n_tags(slar[0]) gt 20 then begin ; we have corsl struct
                    for i=0,slar[i_sl0].numfrq-1 do begin
             if (   (lagConfNsbc[slar[i_sl0].lagconfig[i]] ne $
                     lagConfNsbc[slar[i_sltouse].lagconfig[i]]) or $
                  (slar[i_sl0].channels[i]  ne slar[i_sltouse].channels[i]))$
                           then goto,incompat    ; cant store it in same array
                    endfor
                endif
            endif
            maxrecs=slar[i_sltouse].numrecs
            if gotcal eq 0 then begin
                sclJyl=0
                sclcal=0
            endif else begin
                sclJyl=sclJy
                sclcal=1
            endelse
;
;           see if we need to open a new file
;
            Find=slAr[i_sltouse].fileindex
            if Find ne curFileInd then begin
                if lun ne -1 then free_lun,lun
                lun=-1
                openr,lun,slfileAr[find].path + slfilear[find].file,/get_lun
                curfileind=find
            endif
            point_lun,lun,slAr[i_sltouse].bytepos  ; position to start of scan
            istat=corposonoff(lun,bloc,t,sclcal=sclcal,scljy=scljyl,han=han,$
                          maxrecs=maxrecs)
            if istat eq 1 then begin
;
;           got the data.. store in the bout
;               first time ,allocate the array
;
                if n_bout eq 0 then begin
                    bout=replicate(bloc,maxbout)
                endif else begin
;
;                   make sure structures are compatible
;
                    if corchkstr(bout[0],bloc) eq 0 then goto,incompat
                endelse
                corstostr,bloc,n_bout,bout
                infoAr[0,n_bout]=(i_sl eq i_sltouse)?1:2
                if not gotcal then infoAr[0,n_bout]=infoAr[n_bout]*(-1)
                infoAr[1,n_bout]=i_sl
                n_bout=n_bout+1L
                if verbose then correcinfo,bloc
            endif
        endif
        rec_incompat=0
incompat: if rec_incompat eq 1 then  begin
            incompat[n_incompat]=i_indar
            n_incompat=n_incompat + 1
          endif
skip:
        i_indar=i_indar + iskip             ; next element in indar[] to get
    endwhile
done:
    if n_bout eq 0 then begin
        infoAr=0
        bout=0
    endif else begin
        if n_bout lt maxbout then begin
            bout=temporary(bout[0:n_bout-1])
            infoAr=temporary(infoar[*,0:n_bout-1])
        endif
    endelse
    if n_incompat eq 0 then begin
            incompat=-1
    endif else begin
        if n_incompat lt maxbout then begin
            incompat=incompat[0:n_incompat-1]
        endif
    endelse
    if lun ne -1 then free_lun,lun
    return,n_bout
end
