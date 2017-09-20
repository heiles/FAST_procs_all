;+
;NAME:
;cataloginp - input a pointing catalog
;SYNTAX: nsrc=cataloginp(file,format,retdata,comment=comment,crdsys=crdsys)
;ARGS:
;   file     :string    filename of catatlog
;   format   :int       format for catalog:
;                       1: srcname hh mm ss dd mm ss
;                       2: srcname hhmmss ddmmss
;                       3: srcname hh:mm:ss dd:mm:ss
;                       4: fmt 2 or 3. program checks for :
;   retdata[]:{srccat}  return data here
;                       in retdata.
;KEYWORDS:
;   comment  : string   comment characters for catatlog.def:#
;   crdsys   : string   coord system for coordinates. by defaul
;                       assume 'j': j2000. other is 'b': b1950
;DESCRIPTION:
;   Read in all of the source names and positions catalog specified by
;file
;The returned srccat array will contain:
;help,retdat,/st
;history:
;  
;** Structure CATENTRY, 6 tags, length=52:
;   NAME            STRING     ''           source name
;   RA              FLOAT     Array[3]      hh mm ss.ss 
;   DEC             FLOAT     Array[3]      dd mm dd.dd  (alway positive)
;   DECSGN          INT              0      +/- 1 sign of declination
;   RAH             DOUBLE           0.0    ra in hours (includes sign)
;   DECD            DOUBLE           0.0    dec in hours (includes sign)
;   EOL             STRING                  string dec to end of line
;-
;28jun01 - fixed so aliases worked..
function cataloginp,file,format,retdat,comment=comment,crdsys=crdsys

	crdsysL='j'
	if n_elements(crdsys) gt 0 then crdsysL=strmid(strlowcase(crdsys),0,1)
	crdSysOk='jb'
	if (strpos(crdsysOk,crdsysL) eq -1 ) then begin
			print,"Valid coordSys are : j,b. Invalid input:",crdsys 
			return,-1
	endif
    on_ioerror,doneio
    if n_elements(comment) eq 0 then begin
        comment=';#'
    endif
    if (format lt 1 ) or (format gt 4) then begin
        printf,-2,'illegal format requested:',format
        return,0
    endif
    c='['+comment+']*'
	nlines=readasciifile(file,inpL,comment=comment)
	if nlines eq 0 then return,0
    retdat=replicate({catentry},nlines)
    irec=0L
	start=1
    formatL=format
    for j=0,nlines-1 do begin
		if inpL[j]  eq '' then continue
		inpline=inpL[j]
        strlen=strlen(inpLine)
        tok   =strsplit(inpline,/extract)
        tokInd=strsplit(inpline,len=len)
        ntok=n_elements(tok)
		if ntok lt 3 then continue
		if (ntok ge 2) and (tok[1] eq 'alias') then continue
        retdat[irec].name=tok[0]
        retdat[irec].decsgn=1
        retdat[irec].crdsys=crdsysL
        eol=''
		if (start and ( format eq 4)) then begin	
			formatL=(strpos(tok[1],":") eq -1)?2:3
		endif
        case formatL of
             1 : begin
                if strmid(tok[4],0,1) eq '-' then begin
                   retdat[irec].decsgn=-1
                   tok[4]=strmid(tok[4],1)
                endif
                retdat[irec].ra  =tok[1:3]
                retdat[irec].dec =tok[4:6]
;
;                       position end last token
;
                tokend=tokInd[6] + len[6]
                if strlen gt tokend then eol=strmid(inpline,tokend)
               end
              2 : begin
                  sixtyunp,tok[1],junk,temp
                  retdat[irec].ra=temp
                  sixtyunp,tok[2],junk,temp
                  retdat[irec].decsgn=junk
                  retdat[irec].dec=temp
                  tokend=tokInd[2] + len[2]
                  if strlen gt tokend then eol=strmid(inpline,tokend)
                 end
              3 : begin
				  ras =strsplit(tok[1],":",/extract)
				  decs=strsplit(tok[2],":",/extract)
                  retdat[irec].ra =[float(ras[0]),float(ras[1]),float(ras[2])]
                  retdat[irec].dec=[float(decs[0]),float(decs[1]),$
									float(decs[2])]
				  if retdat[irec].dec[0] lt 0 then begin
                  	retdat[irec].decsgn=-1
				    retdat[irec].dec[0]= -retdat[irec].dec[0] 
				  endif
                  tokend=tokInd[2] + len[2]
                  if strlen gt tokend then eol=strmid(inpline,tokend)
                 end
        endcase
        retdat[irec].eol=eol
        retdat[irec].raH =retdat[irec].ra[0]+retdat[irec].ra[1]/60.D + $
                      retdat[irec].ra[2]/3600.D
        retdat[irec].decD=(retdat[irec].dec[0]+retdat[irec].dec[1]/60.D + $
                          retdat[irec].dec[2]/3600.D)*retdat[irec].decsgn
        irec+=1
	endfor

doneio: 
    if irec ne nlines then begin
        if irec gt 0 then begin
            retdat=retdat[0:irec-1]
        endif else begin
            retdat=''
        endelse
    endif
;
    return,irec
end
