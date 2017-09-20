;+
;NAME:
;shsget - input atm shs data
;SYNTAX: istat=shsget(desc,d,nrec=nrec,posrec=posrec)
;ARGS:
;   desc: {}         stucture returned by shsopen
;
;KEYWORDS:
;   nrec:   long    number of records (hdr/data) to input
; posrec:   long    position to this record before reading (count from 0).
;                   if posrec is not supplied or it is set < 0 then the
;                   next record will be read.
;RETURNS:
;   istat: > 0 number of recs found
;   d[nrec]:  {shsdat}  structure holding data
;
;DESCRIPTION:
;   Input data from the file pointed to by desc (desc is a structure
;returned by shsopen()). The data is returned in the structure d. d will
;hold one record from the .shs file. A record will have multiple ipps
;(for 10 millisec ipps there are 100 records .. 1 second of data).
;If nrec=n is provided with n gt 1 then d[n] will be an array.
;    The user can optionally position in the file before reading
;with the posrec= keywword. 
;
;   The data format on disc is:
;   primary header
;
;   datahdr
;   data
;    slop
;
;EXAMPLES:
;   file='/mnt/daeron/testCont/meteor_08oct2011_000.shs'
;   istat=shsopen(file,desc)
;;   read in the next record:
;   nrec=shsget(lun,d)
;
;; The d struct contains:
;
;  help,d,/st
;   DHDR            STRUCT    -> <Anonymous> Array[1]
;   NIPPS           LONG               100
;   D1              STRUCT    -> <Anonymous> Array[1]
;   D2              STRUCT    -> <Anonymous> Array[1]
;
; help,d.d1,/st
;   TX              INT       Array[2, 100, 100]
;   DAT             INT       Array[2, 16100, 100]
;   CAL             INT       Array[2, 10, 100]
;
; D1 holds the data for channel 1, D2 has the data for channel 2.
; The data is returned as complex so:
;  d1.dat[i0,i1,i2]  where
;   i0 - 2= the i,q complex samples
;   i1 - 16100= the data  samples in 1 ipp
;   i3 - 100 = the 100 ipps in a record
;
;   To read multiple records:
;   nrec=shsget(lun,d,nrec=3)
;; in this case d will be an array of structs: d[3]...
;
;
;NOTES:
; 31aug11.. i was interpreting the tx skip variables incorrectly
;           the txskip,  only tell you
;           the timing offsets. the data is packed together
;           txlen,datalen,noiseLen
;-
;history
;21sep05 = started
;
function shsget,desc,d,nrec=nrec,posrec=posrec
;     
;
;   some constants that belong in an include file
;
    errPos     =-1
    errHdr     =-2
    errDatatype=-3
    errNdim    =-4
    errRead    =-5
    errNchan   =-6
    errEof     =04
    dataTypeSh =2

    point_lun,-desc.lun,curpos
    if curpos lt desc.tblSt then point_lun,desc.lun,desc.tblSt
    if n_elements(nrec) eq 0 then nrec=1
    if n_elements(posrec) gt 0 then begin
		if (posrec ge 0) then begin
        	istat=shspos(desc,posrec)
       		if istat ne 1 then return,errPos
		endif
    endif
    recdone=0
    for irec=0,nrec-1 do begin
;
;   get the data header
;
        istat=shshdr_dat(desc.lun,dhdr)
        if istat ne 1 then begin
            print,"Error reading hdr:"
            return,errHdr
        endif
;
;    first rec, allocate arrays
;
        if irec eq 0 then begin
            case dhdr.datatype of
                'short': dataType=dataTypeSh
                else : begin
                    print,'shsget..unkown datatype:',dhdr.datatype
                    return,errDatatype
                    end
            endcase
            nchan=dhdr.numchannels
            if (nchan lt 1 ) or (nchan gt 2) then begin
                print,'Illegal number channels in hdr:',nchan
                return,errChan
            endif
            ndim=dhdr.numdims
            if ndim ne 2 then begin
                print,"Currently only support tbl dim = 2. Found:",ndim
                return,errNdim
            endif
            dim0=dhdr.dim0
            dim1=dhdr.dim1
            ntotreq=dim0*dim1
            nipps=(nchan eq 1)?dim1:dim1/2L
              a={$
                tx : make_array(2,dhdr.txLen/2L   ,nipps,type=dataType), $
                dat: make_array(2,dhdr.dataLen/2L ,nipps,type=dataType),$
                cal: make_array(2,dhdr.noiseLen/2L,nipps,type=dataType)$
              }
            d= (nchan eq 1) $
                  ?{dhdr : dhdr , $
                    nipps: nipps, $
                    d1   : a    $
                   }        $
                  :{dhdr : dhdr , $
                    nipps: nipps, $
                    d1   : a  , $
                    d2   : a    $
                   }        
            if nrec gt 1 then d=replicate(d,nrec)
            dinp=make_array(2,dim0/2,dim1,type=datatype)
        endif
        on_ioerror,ioerr
        readu,desc.lun,dinp,transfer_count=ntotinp

ioerr: if ntotinp ne  ntotreq then begin
          if ntopinp eq 0 then begin
            if eof(lun) then goto,done
          endif
          print,'read error:',!error_state.msg
          return,errRead
        endif
;
;   move the info to the array
;
        d[irec].dhdr =dhdr
        d[irec].nipps=nipps
        k=0L
;        j=dhdr.txstart
		j=0L
        len=dhdr.txlen/2
        d[irec].d1.tx  =dinp[*,j:j+len-1,k:k+nipps-1]
        j=j + len
        len=dhdr.datalen/2
        d[irec].d1.dat =dinp[*,j:j+len-1,k:k+nipps-1]
        j=j + len
        len=dhdr.noiselen/2
        d[irec].d1.cal =dinp[*,j:j+len-1,k:k+nipps-1]
        if nchan gt 1 then begin
            k=nipps
;            j=dhdr.txstart
              j=0L
            len=dhdr.txlen/2
            d[irec].d2.tx  =dinp[*,j:j+len-1,k:k+nipps-1]
            j=j + len
            len=dhdr.datalen/2
            d[irec].d2.dat =dinp[*,j:j+len-1,k:k+nipps-1]
            j=j + len
            len=dhdr.noiselen/2
            d[irec].d2.cal =dinp[*,j:j+len-1,k:k+nipps-1]
        endif
        recdone=recdone+1
    endfor
done:
    if recdone lt nrec then begin
        if recdone eq 0 then begin
            d=''
        endif else begin
            d=d[0:recdone-1]    
        endelse
    endif
    return,nrec
end
