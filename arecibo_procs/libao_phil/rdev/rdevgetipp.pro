;+
;NAME:
;rdevgetipp - input 1 rdev ipp of data
;SYNTAX   psmp=rdevgetipp(desc,d,dtx,nipps=nipps,posipp=posipp,cmplx=cmplx)
;                     
;ARGS:
;KEYWORDS:
; posipp: long 	position to this ipp before starting. Count from start of
;               this file (for now)
;               < 0 --> use current position
;cmplx  :       if set then return complex data (default is int)
;
;RETURNS:
;   nsmp: long samples we read
;   d[2,nsmp]: float   returned data [IA/QA,nspmp] if not /cmplx
;   d[nsmp]:   complex if /cmplx is set
;
;DESCRIPTION:
;   Input nipps of rdev data from the requested file. You need to call
;rdevopen() once to open the file before using this routine.
;   The returned data is floats  unless /cmplx is set. In that case
;the return value is complex.
;	If the file is a continuation of a previous file (see rdevopen descprev=), then
;the routine will position to the start of the first ipp in the file (files do not
;have integral number of ipps).
;
;History:
;10jan10: fixed some of the documentation, updated to position in secondary files
;         correctly
;26feb08: swapped i,q to get correct sign
;         switched to return float or complex.. no more ints
;-
function    rdevgetipp,desc,d,tx,nipps=nipps,posipp=posipp,cmplx=cmplx 
;
	forward_function rdevcmpipppos
    on_ioerror,ioerr
    point_lun,-desc.lun,curpos

	;    real img indices
;    indr=1
;    indi=0
    indr=0
    indi=1

	usecmplx=keyword_set(cmplx)
	nipps=(n_elements(nipps) eq 0)?1:nipps
    nbits=16 
    npol=1
	posIppL=(n_elements(posipp) gt 0)?posIpp:-1L


	bytesSample=4L
;
;	see if the wrong byteswap code was in pnet.conf
;
    needByteSwap=(((nbits lt 16) && (desc.h1.byteswapcode eq 1))  || $
		((nbits eq 16) && (desc.h1.byteswapcode ne 1)))?1:0
;
;   input the data
;
	nsmpTx=desc.txsmpipp
	nsmpD =desc.dsmpipp
	 nsmpIpp=(nsmpTx + nsmpD)
; 
;	see if we position first
;
	point_lun,-desc.lun,curpos
	if curpos eq 0 then posIppL=0L
	if (posippL ge 0 ) then begin
    	if (rdevposipp(desc,posippL) ne 0) then return,-1 
	endif
; 
	 inbuf=intarr(2*npol,nsmpIpp,nipps)
     readu,desc.lun,inbuf
     if (needByteSwap) then inbuf=swap_endian(inbuf)
;
; 	now the unpacking to tx, d buffers
;
	if nipps gt 1 then begin
    	if useCmplx then begin
       	   tx=reform(complex(inbuf[indr,0L:nsmpTx-1L,*],$
       	                     inbuf[indi,0L:nsmpTx-1L,*]))
       	   d =reform(complex(inbuf[indr,nsmpTx:*,*],$
       	                     inbuf[indi,nsmpTx:*,*]))
    	endif else begin
       		d =fltarr(nsmpD,2,nipps)
       		tx=fltarr(nsmpTx,2,nipps)
       	    d[*,0,*]=inbuf[indr,nsmpTx:*,*]
       	    d[*,1,*]=inbuf[indi,nsmpTx:*,*]
       	    tx[*,0,*]=inbuf[indr,0L:nsmpTx-1L,*]
       	    tx[*,1,*]=inbuf[indi,0L:nsmpTx-1L,*]
		endelse
    endif else begin
		  if useCmplx then begin
           tx=reform(complex(inbuf[indr,0L:nsmpTx-1L],$
                             inbuf[indi,0L:nsmpTx-1L]))
           d =reform(complex(inbuf[indr,nsmpTx:*],$
                             inbuf[indi,nsmpTx:*]))
        endif else begin
            d =fltarr(nsmpD,2)
            tx=fltarr(nsmpTx,2)
            d[*,0,*]=inbuf[indr,nsmpTx:*]
            d[*,1,*]=inbuf[indi,nsmpTx:*]
            tx[*,0,*]=inbuf[indr,0L:nsmpTx-1L]
            tx[*,1,*]=inbuf[indi,0L:nsmpTx-1L]
       endelse
	endelse
    return,nipps
ioerr:
    hiteof=eof(desc.lun)
    on_ioerror,NULL
    point_lun,desc.lun,curpos
    if ( not hiteof ) then begin
            print, !ERR_STRING
            return,-1
    endif else  return,0

end
