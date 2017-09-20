;+
;NAME:
;arch_getmapinfo - get info on maps from the archive
;SYNTAX: nmaps=arch_getmapinfo(yymmdd1,yymmdd2,mapI,projId=projid,srcNm=srcNm,$
;                    procNm=procNm,rcvNum=rcvNum,useslar=useslar,$
;                    slar=slar,slfilear=slfilear
;
;ARGS:
; yymmdd1: long   starting date in the archive to search:eg 030501 .
; yymmdd2: long   ending   date in the archive to search:eg 030801 .
; 
;KEYWORDS: 
; projId : string if provided then limit the maps to this project id.
; srcNm  : string if provided then limit the maps to this source name.
;  procNm: string if provided then limit the maps to this data taking
;                 procedure name. Supported names are:
;                 'cormap1','cormapdec','cordrift'. 
;  rcvNum: int    restrict search to this receiver number.
; useslar:        if set the routine will use the slar,slfilear passed in
;                 by the user (rather than the default archive).
;  slar[]:{corsl} slar passed in by user (if useslar is set) or passed 
;                 back by this routine
;slfilear[]:{slind} slfilear passed in by user (if useslar is set) or 
;                 passed back by this routine.
;
;RETURNS:
;nmaps: long    The number of maps found
;mI[nmaps]:{}   array of mapinfo structures, one foreach map
;
;DESCRIPTION:
;   Mapping can be done with the datataking routines: cormap1,cormapdec,
;and cordrift. The routine cormapinp() can be used to input a single
;map if the user knows the filename and scannumber. The routine
;arch_getmap() can be used to retrieve all map data given a number of
;constraints (date range, projid, srcname, etc..). This  data is returned
;as an array of strips. For some projects, the amount of mapping data is
;too large to recall at once. In this case, arch_getmapinfo() can be
;used to get a summary of the maps that are in the archive, without
;retrieving the actual data. You can than use the summary info
;to decide which maps to input.
;
;   arch_getmapinfo() defines a map as a set of scans in a mapping procedure
;that are contiguous in time and have increasing strip numbers. It returns
;an array of map Info strucutures (one for each map found). 
;  If a  map has 120 samples per strip and 36 strips and the user
;did one complete map and a second map of strips 1 through 32. This
;routine would return a mapInfo structures with two entries.
;  The mapInfo structure contains:
;
;** Structure <8266244>, 12 tags, length=1052, data length=1050, refs=1:
;   SRCNM           STRING    'MRK335'      Name of source
;   PROCNM          STRING    'cordrift'    Name of datataking procedure
;   SMPSTRIP        INT            120      requested samples in a strip
;   REQSTRIPS       INT             36      Requested strips in a map
;   RACENHR         FLOAT          0.105417 Ra center in hours
;   DECCENDEG       FLOAT           19.9528 Dec center in degrees
;   FIRSTSTRIP      INT              1      First strip returned(count from 1)
;   NUMSTRIPS       INT             36      number of strips returned
;   FNAME           STRING    '/proj/a1552/corfile.15nov01.a1552.1'
;   SCANNUM         LONG         131900007  scan number 1st sample,1st strip
;   COMPLETEMAP     INT              1      map is complete
;   HDR             STRUCT    -> HDR Array[1] hdr brd 1, 1st sample,1st strip
;
;
;EXAMPLE:
;   the source 'MRK335' was mapped by project a1552 at lband using cordrift.
;The data was taken nov01,dec01. To get the mapinfo data:
;  srcnM='MRK335'
;  projId='a1552'
;  procNm='cordrift'
;  yymmdd1=011101
;  yymmdd2=031231               ; search over a larger date range
;  nmaps=arch_getmapinfo(yymmdd1,yymmdd2,mI,projId=projId,srcNm=srcNm,$
;                procNm=procNm)
;help,mI
;MI    STRUCT    = -> <Anonymous> Array[29] ; there were 29 maps
;
;It turns out that the maps had two separate centers. You could find
;them by looking at racenhr,deccendeg:
;
;SEE ALSO:
;   arch_getmap(),cormapinp(),cormapinplist().
;
;- 
function arch_getmapinfo,yymmdd1,yymmdd2,mI,projId=projId,srcNm=srcNm,$
                       procNm=procNm,rcvNum=rcvNum,slar=slar,slfilear=slfilear,$
                       useslar=useslar
;
;
    nmaps=0
    a={ srcNm   : ' ' ,$;   source name this map    
        procNm  : ' ' ,$;   procedure name used cordrift,cormap1, etc..
        smpStrip:   0 ,$;   samples in a strip
       reqStrips:   0 ,$;   requested number of strips in a map
       raCenHr  :   0.,$;   central ra  for map
       decCenDeg:   0.,$;   central dec for map
      firstStrip:   0     ,$;first strip of map included
       numStrips:   0     ,$; number of contiguous strips 
       fname    : ' '     ,$; filename holding this info
       scanNum  :  0L     ,$; scan Number first returned strip
       completeMap: 0     ,$; true if complete map..
       hdr      : {hdr}   } ; cor hdr first brd,first,smp,first strip
        
    if n_elements(procNm)  eq 0 then procNm=''

    if not keyword_set(useslar) then begin
        npat=arch_gettbl(yymmdd1,yymmdd2,slar,slfilear,proj=projId,$
                     rcvNum=rcvnum,/cor)
        if npat le 0 then goto,done
        ind=lindgen(npat)
    endif else begin
        npat=n_elements(slar)
        if npat le 0 then goto,done
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
        if count eq 0 then goto,done
        npat=count

    endelse

    print,'arch_gettbl. found ',npat,' nscans.'
;
;   pick out the source name, procname
;
    case 1 of 
        (keyword_set(srcNm) and keyword_set(procNm)): begin
                ii=where((slar[ind].srcname eq srcNm) and $
                         (slar[ind].procname eq procNm),nstrip1)
            end
        keyword_set(srcNm): begin
                ii=where((slar[ind].srcname eq srcNm),nstrip1)
            end
        keyword_set(procNm): begin
                ii=where((slar[ind].procname eq procNm),nstrip1)
            end
        else : begin
               ii=where((slar[ind].procname eq 'cormap1') or $
                        (slar[ind].procname eq 'cordrift') or $
                        (slar[ind].procname eq 'cormapdec') or $
                        (slar[ind].procname eq 'cormapbm'),nstrip1)
            end
    endcase
    if nstrip1 eq 0 then goto,done
    ind=ind[ii]
    print,'getdata found ',nstrip1,' good strips.'
;
;   get all of the headers for first sample of each strip.
;
    maxrecs=nstrip1*4
    n=arch_getdata(slar,slfilear,ind,h,type=1,maxrecs=maxrecs)
    if n eq 0 then goto,done
;
;   keep just header of first board
;
    ii=where(h.std.grpcurrec eq 1)
    h=h[ii]
    if n_elements(h) ne nstrip1 then begin
        print,'there are:',nstrip1,' strips but only found ',n, ' hdrs'
        goto,done
    endif
    mI=replicate(a,nstrip1)
;
;   loop thru each stip finding the start of each map.
;   assume a non contiguous current strip num starts a new map
;
    curstrip=-1
    imapInd=-1
    for i=0,nstrip1-1 do begin
;
;   make sure correct number of samples in a strip, if not, skip it
;   and start a new map
;
        ii=ind[i]
        if (h[i].proc.iar[3] ne  slar[ii].numrecs) then begin
            curstrip=-1
            print,'skip short scan:',slar[ii].scan,slar[ii].numrecs
            goto,botloop1
        endif 
;    
;      start of new map.. strip number not increasing..
;
;       print,i,curstrip+1,h[i].proc.iar[4]
        if (h[i].proc.iar[4] ne curstrip+1) then begin
            imapInd=imapInd+1
            curStrip=h[i].proc.iar[4]
            mI[imapInd].srcNm     =slar[ii].srcname
            mI[imapInd].procNm    =slar[ii].procname
            mI[imapInd].smpStrip  =h[i].proc.iar[3] 
            mI[imapInd].reqStrips =h[i].proc.iar[1] 
            mI[imapInd].firstStrip=curStrip
            mI[imapInd].scannum   =h[i].std.scannumber
            mI[imapInd].numStrips =0
            mI[imapInd].raCenHr      =h[i].pnt.r.reqPosRd[0] *!radeg / 15.
            mI[imapInd].decCenDeg    =h[i].pnt.r.reqPosRd[1] *!radeg
            find=slar[ii].fileindex
            mI[imapInd].fname     =slfilear[find].path +$
                                   slfilear[find].file
            mI[imapInd].hdr       =h[i]
         endif else begin
            curstrip=curstrip+1
         endelse
         mI[imapInd].numStrips  = mI[imapInd].numStrips + 1
         mI[imapInd].completeMap= mI[imapInd].numStrips eq $
                                  mI[imapInd].reqStrips
        if mI[imapInd].completeMap then curStrip=-1
botloop1:
    endfor
    nmaps=imapInd+1
done:
    if nmaps eq 0 then begin
        mI=''   
    endif else begin
        if nmaps ne nstrip1 then mI=mI[0:nmaps-1]
    endelse
    return,nmaps
end
