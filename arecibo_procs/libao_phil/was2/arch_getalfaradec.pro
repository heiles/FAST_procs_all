;+
;NAME:
;arch_getalfaradec - get alfa ra/dec from the archive.
;
;SYNTAX: npts=arch_getalfaradec,yyyymmdd1,yyyymmdd2,raHr,decDeg,$
;                    projid=projid,procname=procname,srcname=srcname,$
;                    numrecs=numrecs,scanRange=scanRange,$
;                    slar=slar,slfilear=slfilear,indAr=indAr,scanAr=scanAr,$
;                    sym=sym,plotit=plotit,verb=verb,gt12=gt12
;ARGS:
;   yyyymmdd1: long  first date to include in data search eg.. 20040903
;   yyyymmdd2: long  last date to include in the data search.
;
;KEYWORDS:
;
;   Keywords to limit the data set:
;
;   projid: string   limit the data to scans taken with this project
;                    idea. An example would be 'a1943'
; procname: string   limit the data to scans taken by this pattern/procedure.
;                    Some example names are: 'onoff','cal','smartf','basket', 
;                    'fixedaz','spiderAn' (n=0,6),'crossAn' (n=0,6), 
;                    'driftmap','driftalt','driftch'
; srcname:  string   limit the data to this source name.
; numrecs:  long     limit the data to scans that have this many records.
;                    This can be used to exclude partial scans.
; scanrange[2]:long  limit the data to scans that are between 
;                    scanrange[0] le scan le scanrange[1]
;
; Keywords for plotting/printing:
;   plotit:          If set then plot the ra,dec values as they are read in.
;                    It replots the data on each block of scans processed.
;                    The last block of scans is always plotted in red.
;   sym   : int      The symbol to used for plotting. The default is
;                    2 (*). other symbols are 1(+), 3(.), 4(triangle).
;   gt12  :          If set then force plotted data to be greater than
;                    twelve hours. Values less than 12 hours are incremented
;                    by 24. This is only for the plotted data. Use this 
;                    when you have data that spans a range like: 22 to 2 hours.
;   verb  :          If set then print scans and number of records as they
;                    are processed (one block at a time).
;  batch  :  int     By default the routine processes one scan at a time.
;                    You can set batch to a larger value (say 10) and it
;                    will read in and process 10 scans at at time. This
;                    will speed up processing if you have the plotit option
;                    set. /plotit replots all points done adding the new
;                    one just processed. If the batch is set to 10 then
;                    the replots will happen every 10 scans rather than
;                    every scan.
;   
;RETURNS:
;  rahr[7,npts]: dbl  The ra in hours for the 7 beams and Npts points.
;decDeg[7,npts]: dbl  The declination in degrees for the beams and Npts points.
;  scanAr[npts]: long The scan numbers for the npts.
;  slar[m]     :{slar}     The slar for the date range and projid. 
;  slfilear[j] :{slfilear} The filename array for the date range and projid.
;  indar[npts] : long      The indices into slar for the data that 
;                     matches all of the criteria specified. 
;DESCRIPTION:
;   arch_getalfaradec will search the was2 archive at the observatory
;and find all of the scans that match the criteria specified by the 
;user. The scans must match all of these criteria to be included (logical and).
;
;   The matching scans are then input batch scans at a time (the default
;for batch is 1). This data is passed to wasalfacmpradec to compute the 
;ra/dec position for the 7 alfa beams for each of the data samples. The
;ra/dec position is for the center of each data sample.
;
;   The computed ra,decs are optionally
;plotted on the screen as they are processed (the user should set the
;horizontal/vertical scale with hor ver if they want to exclude some
;outliers in the plots).
;
;   When done processing, the ra and dec arrays are returned to the 
;caller. The slar and slfilear can optionally be returned thru the
;respective keywords. The indar holding the indices into slar[] for the scans
;that matched the criteria is also returned.
;
;EXAMPLES:
;   Find all of the basket weave scans taken by a1943 between 03sep04
;and 06sep04 on NGC7469. Limit the scans to complete strips of 60 records.
;Return only scans after scan number 424767055L (the previous scans of the
;day had some problems).
;
;yymmdd1=20040903
;yymmdd2=20040906
;srcname='NGC7469'
;projid='a1943'
;numrecs=60
;procname='basket'
;scanrange=[424767055L,500000000L]
;npnts=arch_getalfaradec(yymmdd1,yymmdd2,raAr,decAr,projid=projid,$
;            procname=procname,srcname=srcname,numrecs=numrecs,$
;            scanrange=scanrange,slar=slar,slfilear=slfilear,$
;            indar=indar,scanar=scanar,sym=2,/plotit,/verb,/gt12)
;
;;  now plot out the ra,decs with a different color for each beam.
;
;   ldcolph
;   sym=2
;   hor,min(rahr),max(rahr)
;   ver,min(decdeg),max(decdeg)
;   plot,[0,1],[0,1],/nodata
;   for i=0,6 do $
;       oplot,rahr[i,*],decdeg[i,*],color=colph[i+1],psym=sym
;
;;  plot the average az,za for each scan we found
;
;   plot,slar[indar].azavg,slar[indar].zaavg,psym=2
;
;;  look at what else is available in slar
;   help,slar,/st
;
;SEE ALSO:
;   wasalfcmpradec (was2 routines)
;   alfabmpos      (gen/pnt idl pointing routines
;   arch_getdata   (was2)
;NOTE:
;   You need to run this routine at the AO observatory (since the data 
;archive does not exist at remote sites).
;-
function arch_getalfaradec,yymmdd1,yymmdd2,raHrAr,decDegAr,$
                    projid=projid,procname=procname,srcname=srcname,$
                    numrecs=numrecs,scanRange=scanRange,$
                    slar=slar,slfilear=slfilear,indAr=indAr,scanAr=scanAr,$
                    sym=sym,plotit=plotit,verb=verb,gt12=gt12,batch=batch
;
    common colph,decomposedph,colph
    if not keyword_set(batch) then batch=1
;    batch=10                    ; 10 scans at a time
;    batch=1                     ; 10 scans at a time
    if not keyword_set(sym) then sym=2
    npat=arch_gettbl(yymmdd1,yymmdd2,slar,slfilear,proj=projid,rcv=17)
    if npat eq 0 then return,0
    ind=lindgen(npat)
    if keyword_set(procname) then begin
        ind1=where(slar[ind].procname eq procname,count)
        if count eq 0 then return,0
        ind=ind[ind1]
    endif
    if keyword_set(srcname) then begin
        ind1=where(slar[ind].srcname eq srcname,count)
        if count eq 0 then return,0
        ind=ind[ind1]
    endif
    if keyword_set(numrecs) then begin
        ind1=where(slar[ind].numrecs eq numrecs,count)
        if count eq 0 then return,0
        ind=ind[ind1]
    endif
    if n_elements(scanrange) eq 2 then begin
        ind1=where((slar[ind].scan ge scanrange[0]) and $
                   (slar[ind].scan le scanrange[1]),count)
        if count eq 0 then return,0
        ind=ind[ind1]
    endif
;
    indar=ind
    maxpnts=long(total(slar[indAr].numrecs) + .5)
    npat=n_elements(indAr)
    raHrAr  =dblarr(7,maxpnts)
    decdegAr=dblarr(7,maxpnts)
    scanAr  =lonarr(maxpnts)
    if verb then begin
        lab=string(format='("Found:",i4," scans holding ",i6," samples")',$
                npat,maxpnts)
        print,lab
    endif

    icur=0
    patdone=0
    while (patdone lt npat) do begin
        i1=patdone
        i2=i1+batch-1
        if i2 ge npat then i2=npat-1
        npnts=arch_getdata(slar,slfilear,indAr[i1:i2],b,type=2,/hdronly) &$
        if verb then begin
            lab=string(format='(i4," scan:",i9," with ",i4," records")',$
                        i1+1,b[0].b1.h.std.scannumber,npnts)
            print,lab
        endif
        if npnts gt 0 then begin
            wasalfacmpradec,b,rahr,decdeg  &$
            raHrAr[*,icur:icur+npnts-1] =rahr &$
            decDegAr[*,icur:icur+npnts-1]=decDeg &$
            scanAr[icur:icur+npnts-1]=b.b1.h.std.scannumber
            icur=icur+npnts &$
            if keyword_set(plotit) then begin
                if keyword_set(gt12) then begin
                    raplt=rahrar[*,0:icur-1]
                    ind=where(raplt lt 12.,count)
                    if count gt 0 then raplt[ind]=raplt[ind]+24.
                    plot,raplt,decDegAr[*,0:icur-1],psym=sym &$
                    oplot,raplt[*,icur-npnts:icur-1],$
                    decDegAr[*,icur-npnts:icur-1],psym=sym ,color=colph[2]
                endif else begin
                    plot,raHrAr[*,0:icur-1],decDegAr[*,0:icur-1],psym=sym &$
                    oplot,raHrAr[*,icur-npnts:icur-1],$
                        decDegAr[*,icur-npnts:icur-1],psym=sym ,color=colph[2]
                endelse
            endif
        endif
        patdone=i2+1
    endwhile
    raHrAr   =raHrAr[*,0:icur-1]
    decDegAr =decDegAr[*,0:icur-1]
    scanAr=scanAr[0:icur-1]
    return,icur
end
