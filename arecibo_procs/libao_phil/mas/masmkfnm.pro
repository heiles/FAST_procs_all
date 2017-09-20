;+
;NAME:
;masmkfnm - create filename for fnmI struct
;SYNTAX: fnmINew=masmkfnm(fnmI)
;ARGS:
;   fnmI: struct   fnmI struct from masfilelist
;RETURNS:
;  fnmIN: {}     structure holding the new filename 
;
;DESCRIPTION:
;	masmkfnm will take the parsed info from fnmI and create a new 
;filename and load it into a new fnmI struct. This allows you to 
;create a new fnmI struct by just changing one of the parsed parameters.
;This routine will then fill in the .fname entry to reflect the new values.
;
; The format is:
; dir/proj.date.obs.brdId.seqnum.mas
; where obs is optional
; 
;* Structure PDEVFNMPARS, 8 tags, length=60, data length=60:
;   DIR             STRING    '/share/pdata1/pdev/'
;   FNAME           STRING    'if2noise.20081107.b0s0g0.00000.fits'
;   PROJ            STRING    'if2noise'
;   DATE            LONG          20081107
;   SRC             STRING    ''
;   BM              INT              0
;   BAND            INT              0
;   GRP             INT              0
;   NUM             LONG                 0
;-
function masmkfnm,fnmI
;
    fnmIN=fnmI
	fname=string(format='(a,".",i08,".")',fnmI.proj,fnmI.date)
	if fnmI.src ne '' then begin
		fname+=(fnmI.src + '.')
	endif
	fname+=string(format='("b",i1,"s",i1,"g",i1,".",i05,".")',$
			fnmI.bm,fnmI.band,fnmI.grp,fnmI.num)
	ii=strpos(fnmI.fname,".",/reverse_search)
	suf=strmid(fnmI.fname,ii+1)
	fname+=suf
	fnmIN.fname=fname
    return,fnmIN
end
