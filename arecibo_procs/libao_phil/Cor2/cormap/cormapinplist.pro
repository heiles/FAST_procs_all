;+
;NAME:
;cormapinplist  - input a map from a list of files.
;
;SYNTAX:istat=cormapinplist(flist,scanlist,polABrdNum,polBBrdNum, m,cals,
;                           maxstrips=maxstrips,norev=norev,han=han,
;                           maxrecs=maxrecs,avgsmp=avgsmp)
;
;ARGS:
;   cormapinplist arguments:
;   flist[n]: string  array of files to read data from
;scanlist[n]: long    starting scannumber of the map in each file
;   cormapinp arguments:
;polABrdNum: int  correlator board index (1 thru 4) to take polA data from.
;polBBrdNum: int  correlator board index (1 thru 4) to take polB data from.
;
;KEYWORDS:
;   maxstrips:  long    The maximum number of strips for the completed map
;                      The program will allocate an array of this size when
;                      inputting the data. The default max size is 41 strips
;
;   The following keywords are from cormapinp.
;
;   norev:    When you drive both directions, the routine will normally
;             reverse the odd strips so that the  data,header, and cals of
;             adjacent strips will line up in RA. Setting norev to true 
;             will override this default. The data will be returned in 
;             the order it is taken.
;     han:    if set then hanning smooth the data on input.
;     sl[]:   {sl} scanlist array returned from call a previous call to
;             getsl(). If this keyword is provided then direct access is
;             used rather than sequentially reading the file.
;   maxrecs:  long  If you have more than 300 records in a scan you will have
;                   to set maxrecs to that value.
;    avgsmp:  long  Number of samples to average together. Handy if you've
;                   oversampled each strip. If this number does not divide
;                   evenly into the samples/strip, then samples at the end
;                   will be dropped.
;                   avsmp=0 or 1 is the same as no averaging
;
;RETURNS:
;   istat:    int  1: got map
;                 -1: trouble getting the data
;m[2,pnts/strip,nstrips]:{} array of structures holding the returned 
;                       data and header. (see below for a description).
;cals[nstrips*n]        :{} array of structures containing the cal on,off data
;                        (see below for a description).
;
;DESCRIPTION:
;   cormapinp is used to input an on the fly map from a data file. Large
;maps may be taken a few strips per day and be spread over many datafiles. 
;cormapinplist will input a map that is spread over many files.
;   See cormapinp for a description of the m,cals structures that are
;returned.
;
;EXAMPLE:
;   Suppose the map is spread over 3 days and that the files are
;located in /share/olcor/ with the specified starting scan numbers. The 
;data is in brdpolA=1 and brdPolB=2 with a total of 49 strips.
;You could input the map using:
;
;flist=['corfile.14dec02.a1632.1','corfile.15dec02.A1632.1',$
;         'corfile.16dec02.A1632.1',$
;dir='/share/olcor/'
;scanlist=[234800055L,234900056L,235000053L]
;polABrd=1
;polBBrd=2
;istat=cormapinplist(dir+flist,scanlist,polABrd,polBBrd,m,cals,maxstrips=49)
;
;SEE ALSO:
;   cormapinp(), cor2/arch_getmap
;
;modhistory
;19dec02 started
;07mar04  added calrecs keyword
;-
function cormapinplist,flist,scanlist,polABrdNum,polBBrdNum, m,cals,$
            maxstrips=maxstrips,norev=norev,han=han,maxrecs=maxrecs,$
            avgsmp=avgsmp,calrecs=calrecs
;
; 1. position to scan. read header figure out
;
    forward_function cormapinp

    if not keyword_set(maxstrips) then maxstrips=49
    usecalrecs=arg_present(calrecs)
    maxstripsLoc=maxstrips
    growStrips=maxstrips/2 
    nfiles=n_elements(flist)
    stripsDone=0
    calsDone=0
    m=''
    cals=''
    cordrift=0
    for i=0,nfiles-1 do begin
        openr,lun,flist[i],/get_lun
        if usecalrecs then begin
            stat=cormapinp(lun,scanlist[i],polABrdNum,polBBrdNum,m1,cals1,$
                maxrecs=maxrecs,avgsmp=avgsmp,norev=norev,han=han,$
                calrecs=calrecs1)
        endif else begin
            stat=cormapinp(lun,scanlist[i],polABrdNum,polBBrdNum,m1,cals1,$
                maxrecs=maxrecs,avgsmp=avgsmp,norev=norev,han=han)
        endelse
        free_lun,lun
        if stat lt 0 then  begin
            print,'Error inputs map portion from file:',flist[i],' scan:',$
                scanlist[i]
            return,stat
        endif
        a=size(m1)
        if (a[0] eq 2) then begin
            npnts  =a[2]
            nstrips=1
        endif else begin
            npnts  =a[2]
            nstrips=a[3]
        endelse
;
;       first time in loop , allocate array
;
        if i eq 0 then begin
            ii= (nstrips > maxstripsloc)
            m=replicate(m1[0],2,npnts,ii)
            if string(m1[0].h.proc.procname) eq 'cordrift'  then cordrift=1
            if cordrift then begin
                startStrip=ishft(m1[0].h.proc.iar[0],-10) and 1
                endStrip  =ishft(m1[0].h.proc.iar[0],-1) and 1
                caltype = (startStrip)?1:$
                            (endstrip)?2: 0
            endif else begin
                caltype=ishft(m1[0].h.proc.iar[0],-5) and 3
                if caltype eq 0 then $
                    caltype=(ishft(m1[0].h.proc.iar[0],-8) and 1)?4:0
            endelse
            cals=''
            case 1 of
                caltype eq 0 : calsPerStrip=0  ;none
                (caltype eq 1) or (caltype eq 2): begin
                               calsPerStrip=1  ;
                               cals=replicate(cals1[0],maxstripsLoc)
                               if keyword_set(usecalrecs) then $
                                calrecs=replicate(calrecs1[0],maxstripsLoc)
                               end
                (caltype eq 3) : begin
                               calsPerStrip=2  ;
                               cals=replicate(cals1[0],maxstripsLoc*2)
                               if keyword_set(usecalrecs) then $
                                calrecs=replicate(calrecs1[0],maxstripsLoc*2)
                               end
                (caltype eq 4) : begin
                               calsPerStrip=-1 ; start of each map
                               cals=replicate(cals1[0],nfiles)
                               if keyword_set(usecalrecs) then calrecs=calrecs1
                               end
            endcase
        endif   
        if  ((nstrips + stripsDone) gt maxStripsLoc) then begin
            ii=maxstripsLoc
            maxstripsLoc=(maxstripsLoc + growstrips) > (nstrips+stripsDone)
            m0=temporary(m)
            m=replicate(m0[0],2,npnts,maxstripsLoc)
            m[*,*,0:stripsDone-1]=m0[*,*,0:stripsdone-1]
            m0=''
            if calsperstrip gt 0 then begin
                cals0=temporary(cals)
                cals=replicate(cals0[0],maxstripsLoc*calsPerStrip)
                cals[0: stripsDone*calsperstrip - 1]=$
                            cals0[0: stripsDone*calsperstrip - 1]

                if usecalrecs then begin
                    calrecs0=temporary(calrecs)
                    calsrecs=replicate(calrecs[0],maxstripsLoc*calsPerStrip)
                    calsrecs[0: stripsDone*calsperstrip - 1]=$
                            calsrecs0[0: stripsDone*calsperstrip - 1]
                endif
            endif
        endif
        m[*,*,stripsdone:stripsdone+nstrips-1]=m1
        m1=''
        stripsDone=stripsDone+nstrips
;
;       the cals
;
        n=n_elements(cals1)
        if caltype ne 0 then begin
            cals[calsDone:calsdone+n-1]=cals1
            if usecalrecs then calrecs[calsDone:calsdone+n-1]=calrecs1
            calsDone=calsDone+n
        endif
        cals1=''
        calrecs1=''
    endfor
    if maxStripsLoc gt stripsDone then m=temporary(m[*,*,0:stripsDone-1])
    case 1 of 
        calsPerStrip eq 0: cals=''
        calsPerStrip lt 0: cals=cals[0:nfiles-1]
        calsPerStrip gt 0: cals=cals[0:stripsDone*calsPerStrip-1]
    endcase
    if usecalrecs then begin
        case 1 of 
            calsPerStrip eq 0: calrecs=''
            calsPerStrip lt 0: calrecs=calrecs[0:nfiles-1]
            calsPerStrip gt 0: calrecs=calrecs[0:stripsDone*calsPerStrip-1]
        endcase
    endif
    return,1
end
