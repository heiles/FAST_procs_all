;+
;NAME:
;riget - input an ri record
;SYNTAX: istat=riget(lun,b,scan=scan,numrecs=numrecs,complex=complex,sl=sl,
;                     verbose=verbose,hdr=hdr,search=search)
;ARGS:   lun    : unit number for file (already opened)
;        b[]    : {riget} return data here.
;KEYWORDS:
;       scan    : long . scan to position to before reading the data.
;       numrecs : long .. number of records to return
;       complex : if set then return d1 and or d2 as complex numbers
;                 q (right bnc) real
;                 i (left bnc) imaginary
;       sl[]    : {scanlist} array returned from getsl(lun). This can be used
;                  for random access of files (see generic routines: getsl())
;       verbose : if set then print out timing info
;       hdr     : if supplied, then this is the format of the header to use
;       search  : if set then search for the next header if a bad hdrid is 
;                 found. Use this for datafiles that don't start with a hdr.
;RETURNS:
;        istat  : int
;       nrecs - number of records read..
;           0 - hit eof
;          -1 - could not position to requested scan
;          -2 - bad data in hdr
;DESCRIPTION:
;   Read the next ri numrecs (default 1) records from lun. Start at the current
;record position unless the scan keyword is present.
;The data is returned in the structure b. If numrecs is set greater than
;1 then b[numrecs] will be an array of structures and all the next
;numrec records must be the same type (hdr and data).
;
;   The caller should have already defined the {hdr} structure  before calling
;this routine (usually done in the xxriinit routine for the particular 
;datataking program). The structure contents depends on the complex keyword:
; If keyword complex is not set:
;
;   b.h  header
;     h.std
;     h.ri,proc,pnt,iflo depending on the datataking program used
;   b.d1[2,npts]  floats:  1st or only data channel q,i
;   b.d2[2,npts]  floats:  if both input channels (fifos) used this is the 2nd
;
; In this case dx[0,*] is Q the rightmost bnc of the pair
;              dx[1,*] is I the leftmost bnc  of the pair
;
; If keyword complex is set then:
;   b.h  header
;     h.std
;     h.ri,proc,pnt,iflo depending on the datataking program used
;   b.d1[npts]  complex  1st or only data channel
;   b.d2[npts]  complex  if both input channels (fifos) are used then
;                        this is the second channel.
;
; In this case real (dx[]) is Q the rightmost bnc of the pair
;              img  (dx[]) is I the leftmost bnc of the pair
;EXAMPLES:
;   To use this routine:
;   0. idl
;   1. make sure the path to aodefdir() is in your path directory:
;       !path='/home/phil/idl/gen' + !path  .. if you are at ao.. 
;       You can also put this in your IDL_STARTUP file if you like.
;   2. idl
;   3. @rirawinit       .. sets up the paths, headers for ri data
;   4. openr,lun,'/share/olda/datafile.12feb03.x101.1',/get_lun
;   5. npat=riget(lun,b,numrecs=10,/complex)
;
;TIMING:
;   timing measurements were done on pat. Using 100 records with the 
;listed samples per digitizer. The times are in seconds. The last column
;is the time to process 1 million a/d samples.
;
; nfifo packing complex smples tmtot tmio tmcmp tm1MillionPnts
;
;   1    12       1      16000  .803  .056  .747   .467
;   1     8       1      16000                    1.202
;   1     4       1      16000                    1.093
;   1     2       1      16000                    1.354
;   1     1       1      16384                    1.064
;
;   1    12       0      16000                     .131
;   1     8       0      16000                    1.731
;   1     4       0      16000                    1.649
;   1     2       0      16000                    1.615
;   1     1       0      16384                    1.635
;
;
;   2    12       1      6144  0.788  .079  .710  1.155
;   2     8       1      6144  1.670  .041 1.629  2.652
;   2     4       1     16384  3.925  .054 3.871  2.363
;   2     2       1     16384  3.855  .037 3.818  2.331
;   2     1       1     16384  3.637  .029 3.608  2.202
;
;   2    12       0      6144  0.546  .051  .495   .805
;   2     8       0      6144  2.347  .037 2.310  3.760
;   2     4       0     16384                     3.414
;   2     2       0     16384                     3.306
;   2     1       0     16384                     3.339
;-
; modification history:
; 07jun00 - switched the return order so d[*,0] is polA (left digitizer)
; 08jun00 - check to make sure all the recs are the same scan
; 24aug00 - implement numrecs.., scan keyword
; 04jul02 - copied from riget, added packing
;           output order looks like
;           1fifo 12->1 bits  d1[0,*]= right bnc(q)
;                          d1[1,*]= left bnc (i)
;           2fifo 12->1 bits  d1[0,*]= right bnc(q) left chan
;                             d1[1,*]= left bnc (i)
;                             d2[0,*]= right bnc(q) right chan
;                             d2[1,*]= left bnc (i)
;           1fifo  8 bits  same as 12
; 07jan03 - if multiple records, check that each record after the first
;           is the same: reclen,hdrlen,smpipp,ippsPerBuf,packing
; 12apr03 - cleaned up eof processing at end. was not checking
;           for recsread eq 0 in the cleanup stage...
;timing:
; time to shift independant of shift length
;
function  riget, lun, b,scan=scan,numrecs=numrecs,complex=complex,sl=sl,$
                    hdr=hdr,verbose=verbose,search=search
;
    common riunpcom
    tmiotot=0D
    tmtot  =0D
    tdone  =0D
    tmiotot=0D
    tmcmp  =0D
    tmperpnt=0D
    tenter=systime(1)
;   on_error,1
    maxreclen=2L^18         ; for header search
    if n_elements(hdr) eq 0 then hdr={hdr}
    on_ioerror,ioerr
    retstat=1
    if  not n_elements(numrecs) then numrecs=1
    if  not keyword_set(complex) then complex=0
    recsRead=0L
    if  keyword_set(scan)  then begin
        istat=posscan(lun,scan,1L,sl=sl)
        case istat of
            0: begin 
                print,$
                'riget: position to:',scan,', but found increasing scannumber'
                retstat=-1
               end 
           -1: begin
                print,'riget:position did not find scan:',scan
                retstat=-1
               end
         else: 
         endcase
    endif
    if retstat ne 1 then goto,done
    swapdata=0
    hdrsrch=0
    for i=0L,numrecs-1 do begin
        t1=systime(1)
        point_lun,-lun,curpos 
retryhdr:        readu,lun,hdr
        tmiotot=tmiotot+systime(1)-t1
        if ( string(hdr.std.hdrMarker) ne 'hdr_' ) then begin
            if keyword_set(search) and (i eq 0) and (hdrsrch eq 0) then begin
                point_lun,lun,curpos 
                istat=searchhdr(lun,maxlen=maxreclen)
                if istat eq 1 then begin
                    hdrsrch=1 
                    point_lun,-lun,curpos
                    goto,retryhdr
                endif
            endif
            print,'riget;bad hdr. no hdrid:hdr_h, numrec:',i+1
            retstat=-2
            goto,done
        endif
        if i eq 0 then swapdata= abs(hdr.ri.fifonum) gt 12
        if swapdata then hdr=swap_endian(hdr)
        if (hdr.ri.smpPairIpp gt 65536) then begin
            print,'riget: smpPairIpp > 65535,numrec:',i+1
            retstat=-2
            goto,done
        endif
        if i eq 0 then begin
            pntsPerRec=hdr.ri.smpPairIpp*hdr.ri.ippsPerBuf
            packing=hdr.ri.packing
            smpPerShort=16/packing          ; length reduction from packing
            fifoNum=hdr.ri.fifoNum
            inpWordsPerChn=pntsPerRec/smpPerShort ;32 bit words in 1 channelinp
;
;       if first rec to read, allocate structure
;
            case 1 of
            (fifoNum eq 1) or (fifoNum eq 2): begin
                    if complex then begin
                        a={h:hdr,d1:complexarr(pntsPerRec,/nozero)}
                    endif else begin
                        a={h:hdr,d1:fltarr(2,pntsPerRec,/nozero)}
                    endelse
                    if smpPerShort  eq 1 then begin
                        tmp=intarr(2,inpWordsPerChn)
                    endif else begin
                        tmp=uintarr(2,inpWordsPerChn)
                    endelse
                    numfifo=1
                end
            (fifoNum eq 12): begin
                    if complex then begin
                        a={h:hdr,$
                            d1:complexarr(pntsPerRec,/nozero),$
                            d2:complexarr(pntsPerRec,/nozero)}
                    endif else begin
                            a={h:hdr,$
                                d1:fltarr(2,pntsPerRec,/nozero),$
                                d2:fltarr(2,pntsPerRec,/nozero)}
                    endelse
                    if smpPerShort  eq 1 then begin
                            tmp=intarr(2,2,inpWordsPerChn)
                    endif else begin
                            tmp=uintarr(2,2,inpWordsPerChn)
                    endelse
                    numfifo=2
                end
            else: begin
                    print,'riget: illegal fifoNumber in hdr:',fifoNum
                    retStat=-2
                    goto,done
                end
            endcase
            b=replicate(a,numrecs)
            scanNum=hdr.std.scannumber
            grpNum =hdr.std.grpnum
            if inpWordsPerChn gt 1 then begin
                mask=2^(packing) - 1
                toshift=-packing
                indout=lindgen(inpWordsPerChn)*smpPerShort
                case packing of
                    1:lkup=rilkup1
                    2:lkup=rilkup2
                    4:lkup=rilkup4
                    8:lkup=rilkup8
                else :lkup=0 
                endcase
            endif
        endif else begin    
             if ( (pntsPerRec ne (hdr.ri.smpPairIpp*hdr.ri.ippsPerBuf)) or $
                  (packing    ne (hdr.ri.packing))                      or $
                  (fifoNum    ne (hdr.ri.fifoNum)) ) then begin
                    point_lun,lun,curpos        ; point at this rec again
                    retstat=recsRead            
                    goto,done
             endif
        endelse

            
        b[i].h=hdr
        t1=systime(1)
        readu,lun,tmp
        tmiotot=tmiotot+systime(1)-t1
        if swapdata then tmp=swap_endian(tmp)
        case numfifo  of
            1: begin
                if packing eq 12 then begin
                    if complex then begin
                        b[i].d1=complex(tmp[0,*],tmp[1,*])
                    endif else begin
                        b[i].d1=tmp
                    endelse
                endif else begin
                    tmp0=tmp[0,*]
                    tmp1=tmp[1,*]
                    if complex then begin
                        for j=0,smpPerShort-1 do begin
                            b[i].d1[indout+j]=$
                                complex(lkup[ishft(tmp0,toshift*j) and mask],$
                                        lkup[ishft(tmp1,toshift*j) and mask])
                        endfor
                    endif else begin
                        for j=0,smpPerShort-1 do begin
                            b[i].d1[0,indout+j]=$
                                lkup[ishft(tmp0,toshift*j) and mask]
                            b[i].d1[1,indout+j]=$
                                lkup[ishft(tmp1,toshift*j) and mask]
                        endfor
                    endelse
                endelse
               end
            2: begin
               if packing eq 12 then begin
                    if complex then begin
                        b[i].d1=complex(tmp[0,0,*],tmp[1,0,*])
                        b[i].d2=complex(tmp[0,1,*],tmp[1,1,*])
                    endif else begin
                        b[i].d1=tmp[*,0,*]
                        b[i].d2=tmp[*,1,*]
                    endelse
                endif else begin
                    tmp00=tmp[0,0,*]
                    tmp10=tmp[1,0,*]
                    tmp01=tmp[0,1,*]
                    tmp11=tmp[1,1,*]
                    if complex then begin
                        for j=0,smpPerShort-1 do begin
                            b[i].d1[indout+j]=$
                                complex(lkup[ishft(tmp00,toshift*j) and mask],$
                                        lkup[ishft(tmp10,toshift*j) and mask])
                            b[i].d2[indout+j]=$
                                complex(lkup[ishft(tmp01,toshift*j) and mask],$
                                        lkup[ishft(tmp11,toshift*j) and mask])
                        endfor
                    endif else begin
                        for j=0,smpPerShort-1 do begin
                            b[i].d1[0,indout+j]=$
                                lkup[ishft(tmp00,toshift*j) and mask]
                            b[i].d1[1,indout+j]=$
                                lkup[ishft(tmp10,toshift*j) and mask]
                            b[i].d2[0,indout+j]=$
                                lkup[ishft(tmp01,toshift*j) and mask]
                            b[i].d2[1,indout+j]=$
                                lkup[ishft(tmp11,toshift*j) and mask]
                        endfor
                    endelse
                endelse
                end
        endcase
        recsRead=recsRead+1L
;       print,'riget,scan,grp,numrecs:',$
;           b[i].h.std.scannumber,b[i].h.std.grpnum,numrecs
    endfor
    retstat=recsRead
done:
    tdone=systime(1)
    tmcmp=tdone-tenter-tmiotot 
    if recsRead gt 0 then tmPerPnt=1d6*(tmcmp)/(pntsperrec*1.D*numrecs)
    if keyword_set(verbose) then begin
        lab=string(format=$
    '("tmTot:",f6.3," tmIo:",f6.3," tmCmp:",f6.3," tmCmp1Mpnts:",f6.3)',$
            tdone-tenter,tmiotot,tmcmp,tmperpnt)
        print,lab
    endif
    if recsRead eq 0 then begin
        b=''
    endif else begin
        if recsRead ne numrecs then begin
            b=b[0:recsRead-1]       ; return what we found
        endif
    endelse
    return,retstat
ioerr:
    hiteof=eof(lun)
    on_ioerror,NULL
    if (not hiteof) then begin
        message, !ERR_STRING, /NONAME, /IOERROR
     endif else begin
        if recsRead eq 0 then begin
            retstat=0 
        endif else begin
            if recsRead ne numrecs then begin
                b=b[0:recsRead-1]       ; return what we found
            endif
            retStat=recsRead
        endelse
    endelse
    goto,done
end
