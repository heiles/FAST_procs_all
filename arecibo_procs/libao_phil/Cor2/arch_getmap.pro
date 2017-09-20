;+
;NAME:
;arch_getmap - input a map from the archive
;SYNTAX: nstrips=arch_getmap(yymmdd1,yymmdd2,projId,srcNm,m,cals,$
;                      calSpc,procNm=procNm,polABrd=polABrd,polBBrd=polBBrd,$
;                      rcvNum=rcvNum,smpPerStrip=smpPerStrip,norev=norev,$
;                      avgsmp=avgsmp,han=han,verb=verb,$
;                      useslar=useslar,slar=slar,slfilear=slfilear


;
;ARGS:
; yymmdd1: long   starting date in the archive to search:eg 030501 .
; yymmdd2: long   ending   date in the archive to search:eg 030801 .
; projId : string project id you used for the map (eg 'a1731').
; srcNm  : string source name used for the map.
; 
;KEYWORDS: 
;  procNm: string procedure name used for taking data. Supported names
;                 are: 'cormap1','cormapdec','cordrift'. The default is
;                 'cormap1'
;polABrd: int     correlator board number to take polA (1 thru 4). default
;                 is 1.
;polBBrd: int     correlator board number to take polB (1 thru 4). default
;                 is 1. (This assumes two pols per board).
;  rcvNum: int    restrict search to this receiver number. The default
;                 is all receivers found.
;smpPerStrip:long samples per strip in map. Default is to read it from
;                 the first strip found. Use this parameter if the
;                 first strip found is not complete.
;  norev:         When you drive both directions, the routine will normally
;                 reverse the odd strips so that the  data,header, and cals of
;                 adjacent strips will line up in RA. Setting norev to true
;                 will override this default. The data will be returned in
;                 the order it is taken. The default is false.
; avgsmp:  long   Number of samples to average together. Handy if you've
;                 oversampled each strip. If this number does not divide
;                 evenly into the samples/strip, then samples at the end
;                 will be dropped. avsmp=0 or 1 is the same as no averaging
;                 The default is no averaging.
;    han:         if set then hanning smooth the data on input. The default
;                 is no hanning smoothing.
;useslar:         if set the routine will use the slar,slfilear passed in
;                 by the user (rather than the default archive).
; slar[]:         {corsl} slar passed in by user (if useslar is set) or passed
;                 back by this routine
;slfilear[]: {slind} slfilear passed in by user (if useslar is set) or
;                 passed back by this routine.
;
;RETURNS:
;nstrips: long    The number of strips returned. This may be more than the
;                 requested number of strips in the file if the user
;                 redid some of the strips.
;m[2,smpPerStrip,nstrips]:{} array containg the map info. There is 1 entry
;                 per strip taken. See cormapinp() for a description of
;                 this structure.
;cals[n*nstrips]:{} cal info for each strip. n is 1 for 1 cal per strip
;                   2 for 2 cals per strip (but note the warning below 
;                   for 2 cals per strip).
;calSpc[n*nstrips]:{corget} if supplied then return the actual cal spectra
;                 for each strip (calOn followed by calOff). Use this for
;                 recomputing the cal values with a different mask.
;
;DESCRIPTION:
;   On the fly mapping can be done with cormap1,cormapdec, or the cordrift
;routines. Users could use cormapinp() or cormapinplist() to input the 
;map from one or more files. The routine arch_getmap() provides the
;same functionality as cormapinplist() with the added benefit that it
;locates all of the strips for the map from the data archive.
;
;   To identify the map data in the archive you need to enter:
;1.The range of dates in the archive to search (yymmdd1,yymmdd2).
;2.The project id used for the map.
;3.The source name used for the map.
;4.If the map was not taken with cormap1 you need to supply 
;  the keyword procNm='cormapdec' or procNm='cordrift'
;5.If the same source was mapped with more than one receiver (eg 430,lb)
;  then you need to enter the receiver number to use. If not it will
;  combine all of the data it finds. receiver numbers are:
;  1=327,2=430,3=610,5=lbw,6=lbn,7=sbw,8=sbh,9=cb,11=xb,12=sbn.
;6.By default the routine will take polA, and polB from correlator board
;  1. You can change this with the keyword polABrd=2,polBBrd=3
;
;  arch_getmap searches the archive for the locations of the requested
;dataset. It creates a list of files and starting scannumbers that it 
;then passes to cormapinp() (via cormapinplist). cormapinp() will stop
;reading a file if it finds a strip with fewer than the requested number of 
;strips, or it has input the last strip of the map. arch_getmap() is 
;careful in searching the complete file looking for any strips that the 
;user has redone. These  strips will be included in the returned data. 
;This makes it possible for the returned array m[] to have more strips 
;than the number requested in the map. You can find the stripnumber of 
;each strip from: stripNum=m[0,0,*].h.proc.iar[4]
;
;EXAMPLE:
;   the source 'ca' was mapped by project a1731 at 430 using cormap1 (which
;drives in ra) and cormapdec (which drives in dec). The data was taken
; May through august of 2003. Input both maps.
;
;  src='ca'
;  polABrd=1
;  polBBrd=2
;  rcvnum=2                 ; the 430 dome receiver
;  yymmdd1=030501
;  yymmdd2=030801
;  projId='a1731'
;
;  procNm='cormap1'
;  nstrips=arch_getmap(yymmdd1,yymmdd2,projId,srcNm,mra,procNm=procNm,$
;                        polABrd=polABrd,polBBrd=polBBrd,rcvnum=rcvnum,$
;                        /verb)
;  procNm='cormapdec'
;  nstrips=arch_getmap(yymmdd1,yymmdd2,projId,srcNm,mdec,procNm=procNm,$
;                        polABrd=polABrd,polBBrd=polBBrd,rcvnum=rcvnum,$
;                        /verb)
;SEE ALSO:
;   cormapinp(),cormapinplist().
;
;Note:
;   The routine will now search backwards for the first calon/off of the
;map (if there was one).
;
;   You need to have an idea how much memory the maps will take so you
;don't ask for more memory that your computer can provide. As
;an example: the cormapdec map above used:
;(1024chan)*(4bytes/chan)*(2pol)*(257smp/strip)*(65 strips) is 137 megaBytes
;Remember that the routine will input all of the strips done (including 
;any repeated strips).
;- 
;history:
;07mar04 added useslar,slar,slfilear as keywords
;
function arch_getmap,yymmdd1,yymmdd2,projId,srcNm,m,cals,calSpc,$
                       smpPerStrip=smpPerStrip,procNm=procNm,rcvNum=rcvNum,$
                       polABrd=polABrd,polBBrd=polBBrd,norev=norev,han=han,$
                       avgsmp=avgsmp,verb=verb, useslar=useslar,slar=slar,$
                       slfilear=slfilear

;
;
    if n_elements(procNm)  eq 0 then procNm='cormap1'
    if n_elements(polABrd) eq 0 then polABrd=1
    if n_elements(polBBrd) eq 0 then polBBrd=1

    if keyword_set(useslar) then begin
        npat=n_elements(slar)
        if npat le 0 then goto,nodata
        case 1 of
             keyword_set(projId) and keyword_set(rcvnum):$
                ind=where( (slar.rcvnum eq rcvnum) and $    
                           (slar.projId eq projId) ,count)

             keyword_set(projId) and (not keyword_set(rcvnum)):$
                ind=where( (slar.projid eq projid),count)

             (not keyword_set(projId)) and keyword_set(rcvnum):$
                ind=where( (slar.rcvnum eq rcvnum),count)

             else : begin
                    ind=lindgen(npat)
                    count=npat
                    end
        endcase
        if count eq 0 then goto,nodata

    endif else begin
        npat=arch_gettbl(yymmdd1,yymmdd2,slar,slfilear,proj=projId,$
                     rcvNum=rcvnum,/cor)
        if npat le 0 then goto,nodata
        ind=lindgen(npat)
    endelse
;
;   pick out the source name, procname
;
    ii=where((slar[ind].srcname eq srcNm) and (slar[ind].procname eq procNm),$
            nstrip1)
    if nstrip1 eq 0 then goto,nodata
    ind=ind[ii]
;
;   get all of the headers for first sample of each strip.
;
    n=arch_getdata(slar,slfilear,ind,h,type=1)
    if n eq 0 then goto,nodata
    newSmpPerStrip=0
    if not keyword_set(smpPerStrip) then begin
        smpPerStrip=h[0].proc.iar[3]
        newSmpPerStrip=1
    endif
;
;   keep just header of first board
;
    ii=where(h.std.grpcurrec eq 1)
    h=h[ii]
    if n_elements(h) ne nstrip1 then begin
        print,'there are:',nstrips,' strips but only found ',n, ' hdrs'
        goto,nodata
    endif
    numStripMap=h[0].proc.iar[1]            ; strips per map
;
;   loop through each scan making sure correct number of records.
;   cormapinp() will stop in a file if it sees a strip with fewer 
;   than the correct number of records  or it finds the final strip of the
;   map. Either of these will stop the current scanning of the file.
;   We need to verify that there are no other good strips in the file.
;   if there are, we need to add and extra entry in the scan/file lists
;   
    scanlist=lonarr(nstrip1*2)          
    fileind =lonarr(nstrip1*2)
    icur=0
    gotLast=0
    lastStripWasMax=-1
    curFileInd   =-1
    curStripNum =-1
    lastInd=-1
    for i=0,nstrip1-1 do begin
        ii=ind[i]                       ; index into slar
        needExtraEntry=0
        newFile=0
        if (slar[ii].numrecs eq smpPerStrip) then begin
            needExtraEntry=0
            newFile=slar[ii].fileindex ne curFileInd
            if not newFile then begin
                if lastStripWasMax then needExtraEntry=1
                if lastInd ne -1 then begin
                    jj=where(slar[lastind:ii].srcname ne srcNm,count1)
                    if count1 gt 0 then  needExtraEntry=1
                endif
            endif
            if needExtraEntry or newFile then begin
                scanlist[icur]=slar[ii].scan
                fileind[icur] =slar[ii].fileindex
                icur=icur+1
                curFileInd=slar[ii].fileindex
            endif
            lastStripWasMax=h[i].proc.iar[4] eq numStripMap
        endif else begin
            curFileInd=-1
        endelse
        if keyword_set(verb) then begin
lab=string(format=$
'("fInd:",i2," scn:",i9," nrec:",i3," strpN:",i3," newF:",i2," ndExtr:",i2," lastInd:",i)',$
    slar[ii].fileindex,slar[ii].scan,slar[ii].numrecs,h[i].proc.iar[4],$
            newfile,needExtraEntry,lastInd)
            print,lab
            lastInd=ii
        endif
    endfor
    if keyword_set(verb) then correcinfo,h[0],/inphdr
    if newSmpPerStrip then print,'Using:',smpPerStrip,' samples per strip'
    scanlist=scanlist[0:icur-1]
    fileind =fileind[0:icur-1]
    flist=slfilear[fileind].path + slfilear[fileind].file
;
    ii=where(slar[ind].numrecs eq smpPerStrip,maxstrips)
    istat=cormapinplist(flist,scanlist,polABrd,polBBrd,m,cals,$
            maxstrips=maxstrips,norev=norev,han=han,maxrecs=smpPerStrip,$
                      avgsmp=avgsmp)
    if istat ne 1 then begin
        print,'cormapinplist had trouble reading the data'
        goto,nodata
    endif
    a=size(m)
    nstrips=( a[0] lt 3)? 1 : a[3]
;
;   they want the cal spectra returned.
;
    if arg_present(calSpc) then begin 
        scans=reform(m[0,0,*].h.std.scannumber)
        nstrips=n_elements(scans)
        slArCal=replicate(slar[0],2*nstrips)
        iicals=lonarr(nstrips*2)            ; calon,caloff
        ;
        for i=0,nstrips-1 do begin &$ 
        ;   get indices slar for start of each calon,caloff
        ;
            ii=where(slar.scan eq scans[i],count) &$
            iicals[i*2]  =ii+1 &$
            iicals[i*2+1]=ii+2 &$
        endfor
        nfound=corfindpat(slAr[iicals],indcals,pattype=6,rcv=rcvnum)
        if nfound gt 0 then begin
            indget=lonarr(2,nfound)
            indget[0,*]=iicals[indcals]
            indget[1,*]=iicals[indcals]+1l
             n=arch_getdata(slar,slfilear,indget,calspc,type=3,/han,$
                            incompat=incompat1)
             if n_elements(incompat1) gt 0 then begin
                lab=string(format=$
'("Warning..",i4," cal spectra taken with different configuration")',$
                    n_elements(incompat1))
                print,lab
             endif
                        
                
        endif else begin
            calspc=''
        endelse
    endif
    return,nstrips
nodata:
    return,0
end
