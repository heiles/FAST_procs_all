;+
;NAME:
;waspwr - return power information for a number of recs
;SYNTAX: nrecs=waspwr(desc,reqrecs,pwra,lasthdr)
;ARGS:
;   desc     - descriptor opened via wasopen.
;   reqrecs  - requested records to return
;
;RETURNS:
;   pwra     - returns an array pwra[nrecs]  of {corpwr} struct
;   nrecs    - number of recs found, 0 if at eof, -1 if hdr alignment/io error
;
;DESCRIPTION:
;
;   Return the total power information for the requested number of
;records. The data is returned in the array pwra. Each element of the
;array contains:
;
;pwra[i].scan - scan number
;pwra[i].rec  - record number
;pwra[i].time - seconds from midnight end of record.
;pwra[i].nbrds- number of boards in use
;pwra[i].az   - az (deg) end of this record.
;pwra[i].za   - za (deg) end of this record.
;pwra[i].azErr- az (asecs great circle) end of this record.
;pwra[i].zaErr- za (asecs great circle) end of this record.
;pwra[i].pwr[2,4] - total power info. first index in pol1,pol2
;                   2nd index are 4 correlator boards.
;
;There will only be valid data in the first pwra[i].nbrds entries of
;pwra.
;   In pwra[i].[i,j], i=0,1 will be pola, polb if two polarizations were
;recorded in the board. If only one polarization was recorded on the
;board, then i=0 holds the data (either pola,polB) and i=1 has no data.
;-
;history:
;02feb04 - stole from corwpr()
;20aug04 - fixed bug. was not returning the power data correctly.
;          was being returned in the order stored in the fits file,
;          not the order of the boards (a,b)1  (a,b)2 etc..
;
function waspwr,desc,reqrecs,pwra,lasthdr
   on_error,0
    reqRecL=reqrecs
    istat=wasalignrec(desc,scanInd=iscanSt,recind=irecSt)
    if istat ne 1 then return,istat
;
;    clip to end of file
;
    recsLeft=desc.totrecs-(desc.scanI[iscanSt].cumrecstartind+irecSt)
    if recsLeft lt reqRecL then reqRecL=recsLeft
    lastRecInd=(desc.scanI[iscanSt].cumrecstartind+irecSt)+reqRecL - 1L
;
;   figure out last rowInd of file to read  
;   1. compute number of recs needed curpos in scan to 
;      start of last scan to use.
;   2. compute extra recs last scan needed
;   3. compute the cumulative row for the rec of the last scan 
;    
;   number of scan we move forward to get to the end 
;
    ind=where(desc.scanI[iscanSt:*].cumrecstartInd le lastRecInd,count)
    iscanE=iscanSt+(count-1)            ; this is the end scan index
    if (iscanE eq iscanSt) then begin   ; if in the same scan...
        irecE= irecSt + reqRecL - 1L
    endif else begin
        irecE = reqRecL - (desc.scanI[iscanE].cumRecStartInd - $
            (desc.scanI[iscanSt].cumRecStartInd+irecSt )) - 1L
    endelse
    rowEndInd=desc.scanI[iscanE].rowStartInd +$
              (irecE+1L)*desc.scanI[iscanE].rowsInRec-1L
    rowRange=[desc.curpos + 1,rowEndInd+1L]
    pwra=replicate({corpwr},reqRecl)
;
;   time Ast
;
    errmsg=''
    fxbread,desc.lun,time,'CRVAL5',rowRange,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    timeAst= long((time - 4.)*3600.)
    ind=where(timeAst lt 0L,count)
    if count gt 0 then timeAst[ind]=timeAst[ind]+86400L
;
;   azimuth
;
    fxbread,desc.lun,az,desc.colI.az,rowRange, errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr

;
;   main elevation .. assume dome..
;
    fxbread,desc.lun,grza,desc.colI.el,rowRange,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
	grza=90.-grza

;
;   az,za error.. fits file has the sum, split evenly between
;   az and za
;
    fxbread,desc.lun,posErr,'CUR_TOL',rowRange, errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   lag0 pwrratio
;
    fxbread,desc.lun,lag0,'TOT_POWER',rowRange,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr

    posErr=sqrt(1./2.)*posErr
;
;   need to fold multiple rows/rec into single entries
;
    numScansUsed=iscanE-iscanSt + 1l
    prec=0L
    prow=0L
    for i=0,numScansUsed - 1 do begin
        iscn  =iscanSt+i
		if desc.scanI[iscn].recsInScan gt 0 then begin
        irec1 =(i eq 0)? irecSt:0l
        irec2 =(i eq (numScansUsed-1L))?irecE:desc.scanI[iscn].recsInScan-1l 
        recsUsed=irec2-irec1 + 1L
        rowsUsed=recsUsed*desc.scanI[iscn].rowsInRec
        ind=lindgen(recsUsed)
        indrow=ind*desc.scanI[iscn].rowsInRec + prow
        prec2=prec+recsUsed-1L
        pwra[prec:prec2].time =timeAst[indrow]
        pwra[prec:prec2].az   =az[indrow]
        pwra[prec:prec2].za   =grza[indrow]
        pwra[prec:prec2].azerr=posErr[indrow]
        pwra[prec:prec2].zaerr=posErr[indrow]
        pwra[prec:prec2].scan =desc.scanI[iscn].scan
        pwra[prec:prec2].rec  =ind + irec1 + 1
        pwra[prec:prec2].nbrds=desc.scanI[iscn].nbrds
        nbrds=desc.scanI[iscn].nbrds
        for ibrd=0,nbrds-1 do begin
            pwra[prec:prec2].pwr[0,ibrd]=$
				lag0[indrow+ desc.scanI[iscn].ind[0,ibrd]] 
            if (desc.scanI[iscn].nsbc[ibrd] gt 1) then $
                pwra[prec:prec2].pwr[1,ibrd]=$
				lag0[indrow+ desc.scanI[iscn].ind[1,ibrd]] 
        endfor
        prow=prow+rowsUsed
        prec=prec+recsUsed
		endif
    endfor
;
;   return the last header for compatibility
;
    desc.curpos=rowEndInd - desc.scanI[iscanE].rowsInRec + 1
    istat=wasftochdr(desc,lasthdr)
    desc.curpos=rowEndInd + 1L
;
    return,1

hdrreaderr:
    print,'error reading fits hdr:',errmsg
    return,-1

end
