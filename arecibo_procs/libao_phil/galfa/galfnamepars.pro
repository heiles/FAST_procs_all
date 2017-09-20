;+
;NAME:
;galfnamepars - parse a fits filename.
;
;SYNTAX: istat=galfnamepars(filename,nmpars)
;
;ARGS:
;filename: string    fits filename
;
; RETURNS: 
;   istat: int       1 - fits filename format is ok.
;                    0 - filename is not a standard was fits filename
;  nmpars: {}        return structure with filename parsed into 
;                    variables. 
;
;DESCRIPTION:
;   Parse a spectral line was file into its component parts. The 
;returned structure contains:
;   
;help,nmpars,/st
;   DIR    STRING    '/share/galfa/',;dir with trailing '/'
;                                       ;(or blank if no dir in filename)
;   WAPP   STRING    'galfa'
;   DATE   STRING    '20050709' 
;   PROJID STRING    'a2004'
;   SEQNUM   LONG    6
;   FITS   STRING    'fits'
;
;-
;
function  galfnamepars,filename,nmpars
;
    val=strsplit(filename,'.',/extract)
    nval=n_elements(val)
    if nval lt 5 then return,0
;
nmpars={   dir: '' , $; includes trailing slash
           galfa: '', $; should be galfa
           date: '', $; yyyymmdd ast string
         projId: '', $; projid (eg. a2040)
          seqnum:  0L , $; seq number. (integer)
           fits: ''}  ; should be 'fits' 
;
;  see where galfa starts in the first token
;
    len0=strlen(val[0])
    n=strpos(val[0],'galfa',/reverse_search)
    case n of
      -1 : return ,0
       0 : begin
             if len0 ne 5 then return,0
             dir=''
           end
     else: begin
            dir=strmid(val[0],0,n)
            if strmid(dir,strlen(dir)-1) ne '/' then dir=dir + '/'
           end
    endcase
    nmpars.dir   =dir
    nmpars.galfa  ='galfa'
    nmpars.date  =val[1]
    nmpars.projId=val[2]
    nmpars.seqnum=long(val[3])
    if val[4] ne 'fits' then return,0
    nmpars.fits  =val[4]
    return,1
end
