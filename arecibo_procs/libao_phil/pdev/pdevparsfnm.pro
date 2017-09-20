;+
;NAME:
;pdevparsfnm - parse a pdev file name
;SYNTAX: istat=pdevparsfnm(filename,fnmI)
;ARGS:
;   filename: string  pdev filename to parse
;RETURNS:
;  istat: int  1 if valid pdev name, 0 if not a valid pdev name
;  fnmI : {}     structure holding the parsed information.
;
; The format is:
; dir/proj.date.obs.brdId.seqnum.pdev
; where obs is optional
;
;EXAMPLE:
; filename='/share/pdata/pdev/agc110443/x107.20070123.agc110443.b0a.00000.pdev'
; istat=pdevparsfnm(filename,fnmI)
;IDL> help,fnmI,/st
;
;* Structure PDEVFNMPARS, 8 tags, length=60, data length=60:
;   DIR             STRING    '/share/pdata/pdev/agc110443/'
;   FNAME           STRING    'x107.20070123.agc110443.b0a.00000.pdev'
;   PROJ            STRING    'x107'
;   DATE            LONG          20070123
;   src             STRING    'agc110443'
;   bm              INT           0
;   BAND            INT           0
;   grp             INT           0
;   NUM             LONG          0
;-
function pdevparsfnm,filename,fnmI
;
    fnmI={pdevfnmpars}
    basename=basename(filename,dirNm=dirNm,nmLen=nmLen)
    if nmLen[1] eq 0 then return,0
    fnmI.dir=dirNm
    fnmI.fname=basename
    aa=strsplit(basename,'.',count=count,/extract,/preserve_null)
    case 1 of 
     count lt 5: return,0
     count eq 5: ii=1
     count eq 6: ii=0
     count gt 6: return,0
    endcase
    
    if aa[5-ii] ne 'pdev' then return,0
    if strmid(aa[3-ii],0,1) ne 'b'  then return,0
;
    fnmI.proj=aa[0]
    fnmI.date=long(aa[1])
    fnmI.src =(ii eq 0)?aa[2]:''
    fnmI.bm=long(strmid(aa[3-ii],1,1))
    ll=strlen(aa[3-ii])

    fnmI.band=((strmid(aa[3-ii],ll-1,1) eq 'a') or $
                  (strmid(aa[3-ii],ll-3,1) eq '0')) ?0:1

    fnmI.grp =((strmid(aa[3-ii],ll-1,1) eq 'a') or $
                  (strmid(aa[3-ii],ll-1,1) eq '0')) ?0:1

    fnmI.num=long(aa[4-ii])
    return,1
end
