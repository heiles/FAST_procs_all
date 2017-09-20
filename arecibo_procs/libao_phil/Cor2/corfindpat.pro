;+
;NAME:
;corfindpat - get the indices for the start of a pattern
;
;SYNTAX: nfound=corfindpat(sl,indar,pattype=pattype,rcv=rcv)
;
;ARGS:  
;   sl[]:   {getsl} scan list array from getsl
;
;KEYWORDS:
;   pattype: int  Type of pattern we are looking for.
;                 1 - on/off position switch with cal on/off
;                 2 - on/off position switch whether or not cal there
;                 3 - on followed by cal on ,off
;                 4 - heiles calibrate scan two crosses
;                 5 - heiles calibrate scan 1 or more  crosses
;                 6 - cal on,off
;                 7 - x111auto with calonoff
;                 8 - x111auto with or without cal
;                 9 - heiles calibrate scan 4 crosses
;
;                 If not provided than pattype 1 is the default.
;
;      dosl: lun  if keyword dosl is set to a valid open file, then this 
;                 routine will do the sl=getsl(lun) call and return the 
;                 scan list in sl.
;      rcv : int  if supplied then only find patterns for this receiver.
;                 1..12 (see helpdt feeds) for a list of the feeds 
;RETURNS:
; indar[npat]: long indices into sl[] for start of the pattern
;   npat     : long number of patterns found
;
;DESCRIPTION:
;   corfindpat() is used for the automatic processing of entire datafiles. 
;It processes a scanlist array (returned by getsl()) and returns an array of
;pointers for the start of all the completed patterns of a particular type 
;that are located in the datafile. Patterns can be: on/off position switching,
;heiles calibration runs, on with cal on/off,..etc.  
;
;   The requirements for a completed scan depend on the pattern type:
;
;  type   order needed                requirements
;   1     posOn,posOff,calon,caloff. Number of on recs must equal number of
;                                    off recs
;   2     posOn,posOff.              Number of on recs must equal number of
;                                    off recs.
;   3     posOn,calon,caloff.        
;   4     calon,caloff,heiles calibrate scan with 2 crosses. 
;                                    nrecs in each cross is the same.
;   5     calon,caloff,heiles calibrate scan with at least 1 cross. 
;                                    nrecs in each cross is the same.
;   6     calon,caloff
;   7     x111auto (60recs) calon,caloff
;   8     x111auto (60recs)
;   9     calon,caloff,heiles calibrate scan with 4 crosses 120 samples/strip
;                                    nrecs in each cross is the same.
;   
;   You can call sl=getsl(lun) once prior to this routine, or you can
;set the keyword dosl=lun and it will create the sl array and return it.
;It is also possible to limit the pattern to a particular receiver using
;the rcv=rcvnum keyword.
;
;EXAMPLE:
;   openr,lun,'/share/olcor/corfile.23aug02.x101.1',/get_lun
;   sl=getsl(lun)
;;   get poson,off,followed by cal on,off
;   npat=corfindpa(sl,indfound)
;   for i=0,npat-1 do begin
;      scan=sl[indfound[i]].scan
;      .. process this scan
;   
;;  get ons followed by cal on,off. have the routine do the sl search.
;;  only get data for cband (rcv=9)
;   openr,lun,'/share/olcor/corfile.23aug02.x101.1',/get_lun
;   npat=corfindpa(sl,indfound,dosl=lun,pattype=3,rcv=9)
;
;SEE ALSO: arch_gettbl,mmfindpattern,getsl (in general routines)
;
;NOTE: 
;There is also a record type in the {sl} structure that lists the 
;name of the active pattern when the data was taken. It's coding and the 
;coding for this routine are not the same (sorry..). It may or may
;not be accurate (for some test data, the pattern type is not set so the
;last one supplied is used). Corfindpat differs in that it  will
;try and verify that the pattern is what it says it is and that it is
;complete (eg calon followed by caloff). 
;   
;-
function corfindpat,sl,indfound,pattype=pattype,dosl=lun,rcv=rcv
;
    if not keyword_set(pattype) then pattype=1
    if keyword_set(lun) then sl=getsl(lun)
    if not keyword_set(rcv) then rcv=0
    npat=0
    nsl=n_elements(sl)
    case 1 of
;------------------------------------------
;   position on/off with cal onoff
;
    (pattype eq 1): begin
        numinpat=4L
        indPosOn =where(sl.rectype eq 3,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has 3 scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 4) and $
                   (sl[indposon + 2].rectype eq 1) and $
                   (sl[indposon + 3].rectype eq 2),npat)
        if npat gt 0 then indfound=indposon[ind]
    end
;
;   poson,posoff.. cal not important
;
    (pattype eq 2): begin
           numinpat=2L
        indPosOn =where(sl.rectype eq 3,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has 1 scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 4) ,npat)
        if npat gt 0 then indfound=indposon[ind]
    end         
;------------------------------------------
;   position on  with cal onoff
;
    (pattype eq 3) : begin
        numinpat=3L
        indPosOn =where(sl.rectype eq 5,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has 3 scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 1) and $
                   (sl[indposon + 2].rectype eq 2),npat)
        if npat gt 0 then indfound=indposon[ind]

    end
;------------------------------------------
;   heiles calibrate scan 1 or two crosses
;
    (pattype eq 4) : begin
        numinpat=6
        indPosOn =where(sl.rectype eq 1,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has 3 scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 2) and $
                   (sl[indposon    ].numrecs eq sl[indposon+1].numrecs) and $
                   (sl[indposon    ].numrecs gt 0) and $

                   (sl[indposon + 2].procname eq 'corcrossch') and $
                   (sl[indposon + 2].numrecs eq 60) and $

                   (sl[indposon + 3].numrecs eq 60) and $
                   (sl[indposon + 3].procname eq 'corcrossch') and $

                   (sl[indposon + 4].numrecs eq 60) and $
                   (sl[indposon + 4].procname eq 'corcrossch') and $

                   (sl[indposon + 5].numrecs eq 60) and $
                   (sl[indposon + 5].procname eq 'corcrossch'), npat)
        if npat gt 0 then indfound=indposon[ind]
    end
;------------------------------------------
    (pattype eq 5) : begin
        numinpat=4
        indPosOn =where(sl.rectype eq 1,count) ; start cal on
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has  scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 2) and $

                   (sl[indposon + 2].procname eq 'corcrossch') and $
                   (sl[indposon + 2].numrecs eq 60) and $

                   (sl[indposon + 3].numrecs eq 60) and $
                   (sl[indposon + 3].procname eq 'corcrossch'), npat)
        if npat gt 0 then indfound=indposon[ind]
    end
;------------------------------------------
;    cal onoff
;
    (pattype eq 6) : begin
        numinpat=2L
        indPosOn =where(sl.rectype eq 1,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has 1 scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 2),npat) 
        if npat gt 0 then indfound=indposon[ind]
    end
;------------------------------------------
;   x111auto with calon/off
;
    (pattype eq 7) : begin
        numinpat=3
        indPosOn =where(sl.procname eq 'x111auto' and $
                        sl.numrecs   eq 60,count) ; start x11auto
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pos ON has  scans before end
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 1) and $
                   (sl[indposon + 2].rectype eq 2),npat)
        if npat gt 0 then indfound=indposon[ind]
    end
;------------------------------------------
;   x111auto  ignore cal
;
    (pattype eq 8) : begin
        indfound =where(sl.procname eq 'x111auto' and $
                   sl.numrecs   eq 60,npat) ; start x11auto
        if npat eq 0 then goto,done
    end
;------------------------------------------
;   heiles calibrate scan 4 cross, 120 samples long
;
    (pattype eq 9) : begin
		patNm='corcrosschL'
        numinpat=10
        nrecs=60
        indPosOn =where(sl.rectype eq 1,count)
        if count eq 0 then goto,done
        counti=count
;
;       make sure last pat is complete for index checks
;
        while ((indposOn[count-1] + numinpat) gt nsl) do begin
            count=count-1
            if count eq 0 then goto,done
        endwhile
        if count ne counti then indposon=indposon[0:count-1]
        ind=where( (sl[indposon + 1].rectype eq 2) and $
                   (sl[indposon    ].numrecs eq sl[indposon+1].numrecs) and $
                   (sl[indposon    ].numrecs gt 0) and $

                   (sl[indposon + 2].procname eq patNm) and $
                   (sl[indposon + 2].numrecs eq nrecs) and $

                   (sl[indposon + 3].numrecs eq nrecs) and $
                   (sl[indposon + 3].procname eq patNm) and $

                   (sl[indposon + 4].numrecs eq nrecs) and $
                   (sl[indposon + 4].procname eq patNm) and $

                   (sl[indposon + 5].numrecs eq nrecs) and $
                   (sl[indposon + 5].procname eq patNm) and $

                   (sl[indposon + 6].numrecs eq nrecs) and $
                   (sl[indposon + 6].procname eq patNm) and $

                   (sl[indposon + 7].numrecs eq nrecs) and $
                   (sl[indposon + 7].procname eq patNm) and $

                   (sl[indposon + 8].numrecs eq nrecs) and $
                   (sl[indposon + 8].procname eq patNm) and $
            
                   (sl[indposon + 9].numrecs eq nrecs) and $
                   (sl[indposon + 9].procname eq patN), npat)
        if npat gt 0 then indfound=indposon[ind]
    end

;------------------------------------------
;
    else: message,'illegal pattern type requested'
    endcase
;------------------------------------------
done:
    if (npat gt 0) and keyword_set(rcv) then begin
        ind=where(sl[indfound].rcvnum eq rcv,count) 
        if count gt 0 then begin
            indfound=indfound[ind]
            npat=n_elements(indfound)
        endif else begin
            npat=0
        endelse
    endif
    return,npat
end
