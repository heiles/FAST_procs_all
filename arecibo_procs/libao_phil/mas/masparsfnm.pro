;+
;NAME:
;masparsfnm - parse a mas file name
;SYNTAX: istat=masparsfnm(filename,fnmI)
;ARGS:
;   filename: string  mas filename to parse
;RETURNS:
;  istat: int  1 if valid mas name, 0 if not a valid mas name
;  fnmI : {}     structure holding the parsed information.
;
; The format is:
; dir/proj.date.obs.brdId.seqnum.mas
; where obs is optional
;
;EXAMPLE:
; filename='/share/pdata/mas/agc110443/x107.20070123.agc110443.b0a.00000.mas'
; istat=masparsfnm(filename,fnmI)
;IDL> help,fnmI,/st
;
;* Structure PDEVFNMPARS, 8 tags, length=60, data length=60:
;   DIR             STRING    '/share/pdata1/pdev/'
;   FNAME           STRING    'if2noise.20081107.b0s0g0.00000.fits'
;   PROJ            STRING    'if2noise'
;   DATE            LONG          20081107
;   BM              INT              0
;   BAND            INT              0
;   GRP             INT              0
;   NUM             LONG                 0
;-
function masparsfnm,filename,fnmI
;
    fnmI={masfnmpars}
    basename=basename(filename,dirNm=dirNm,nmLen=nmLen)
    if nmLen[1] eq 0 then return,0
    fnmI.dir=dirNm
    fnmI.fname=basename
    aa=strsplit(basename,'.',count=count,/extract,/preserve_null)
	if count ne 5 then  return,0
    
    if aa[4] ne 'fits' then return,0
    if strmid(aa[2],0,1) ne 'b'  then return,0
;
    fnmI.proj=aa[0]
    fnmI.date=long(aa[1])
    fnmI.bm  =long(strmid(aa[2],1,1))
    fnmI.band=strmid(aa[2],3,1)
    fnmI.grp =strmid(aa[2],5,1)
    fnmI.num =long(aa[3])
    return,1
end
