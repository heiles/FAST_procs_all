;+
;NAME:
;rdevget - input pdev radar data
;SYNTAX   psmp=rdevget(desc,nSmpReq,d,pos=pos,cmplx=cmplx,rawbuf=rawbuf,$
;					   dec=dec)
;                     
;ARGS:
;  desc : {}     returned from rdevopen()
;nSmpReq:long number of sample points requested. This is the decimated
;                count.
;KEYWORDS:
; pos   : long 	if set then start reading this many datasamples from the
;               front of the file. It skips the header automatically
;               < 0 --> use current position
;cmplx  :       if set then return complex data (default is int)
;rawbuf:   int  if set then return the raw input buffer here (before
;               negative correction or byteswapping.
;dec   : long   decimate the input by this amount using a boxcar.
;               0,1 --> no decimation.
;
;RETURNS:
;   nsmp: long samples we read
;   d[nsmp,2*npol]: float   returned data [*,IA/QA,IB,QB] if not /cmplx
;   d[nsmp,npol]:   complex if /cmplx is set
;
;DESCRIPTION:
;   Input sampled data from pdev radar processor. You need to call
;rdevopen() once to open the file before using this routine.
;   The returned data is floats  unless /cmplx is set. In that case
;the return value is complex.
; If 2 pols are available then the 2nd dimension of d holds :
; polAI,polAQ,polBI,polBQ.
;History:
;26feb08: swapped i,q to get correct sign
;         switched to return float or complex.. no more ints
;-
function    rdevget,desc,nsmpReq,d,pos=pos,cmplx=cmplx,rawbuf=rawbuf
;
;   value for 4 bit lookups
;
;    real img indices
	indr=1
    indi=0
;
    on_ioerror,ioerr
    point_lun,-desc.lun,curpos

;    real img indices
;    indr=1
;    indi=0
;    switch 07feb13
     indr=0
     indi=1
;	print,"indr,i:",indr,indi

	startData=(desc.smpoffstFile eq 0)?1024L:0L
	usecmplx=keyword_set(cmplx)
	usepos=(n_elements(pos) eq 0)?0:(pos lt 0)?0:1
;    now always 16 bits for rdev aeronomy
;	case  (h.h2.bitsel) of
    nbits=16 
    npol=1

	bytesSample=(2*nbits)*npol/8L
	if (bytesSample eq 0 ) then  begin
		print,'2 bit sampling not yet supported'
		return,-1
	endif
	if usepos then point_lun,desc.lun,startData+pos*(bytesSample*1L)
;
;	see if the wrong byteswap code was in pnet.conf
;
    needByteSwap=(((nbits lt 16) && (desc.h1.byteswapcode eq 1))  || $
		((nbits eq 16) && (desc.h1.byteswapcode ne 1)))?1:0
;
;   input the data
;
	 inbuf=intarr(2*npol,nsmpReq)
     readu,desc.lun,inbuf
     if arg_present(rawbuf) then rawbuf=inbuf
     npts=n_elements(inbuf)
     nsmp=npts/(2*npol)
     if nsmp lt nsmpReq then inbuf=inbuf[*,0:nsmp-1]
     if (needByteSwap) then inbuf=swap_endian(inbuf)
;
; 	now the unpacking
;
    if useCmplx then begin
       d=reform(complex(inbuf[indr,*],inbuf[indi,*]))
    endif else begin
       d=fltarr(nsmp,2)
       d[*,0]=inbuf[indr,*]
       d[*,1]=inbuf[indi,*]
    endelse
    return,nsmp
ioerr:
    hiteof=eof(lun)
    on_ioerror,NULL
    point_lun,desc.lun,curpos
    if ( not hiteof ) then begin
            print, !ERR_STRING
            return,-1
    endif else  return,0

end
