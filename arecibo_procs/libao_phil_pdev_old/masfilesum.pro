;+
;NAME:
;masfilesum - get summary info for files
;SYNTAX: nsum=masfilesum(flist,sumI,fnmI=fnmI)
;
;ARGS:
; flist[n]:strarr filenames for summary. Includes directory.
;KEYWORDS:
;fnmI[n]:{}       structure returned by masfilelist. If this keyword is
;                 present then ignore flist and use fnmI for the files
;                 to use.
;RETURNS:
;    nsum: long    number of summaries we return:
; sumI[n]: {}      summary info for mas files.
;DESCRIPTION:
;   Return summary info for a list of files. You can specify the files with
; the argument flist or the keyword fnmI. 
;   The returned summary info contiains:
; help,sumI,/st
;   OK      INT    1
;   FNAME   STRING '/share/pdata1/pdev/x108.20080530.b0s0g0.00000.fits'
;   FSIZE   LONG64 84389676   .. bytes in file
;   NROWS   LONG   4          .. rows in fits file
;   DUMPROW LONG   319        .. dumps in first row
;   DATE    LONG   20080530   .. yyyymmdd
;   BM      INT    0          .. 0..6 for alfa
;   BAND    INT    0          .. 0,1 low,hi band (at if)
;   GRP     INT    0          .. grp 0,1
;   NUM     LONG   0          .. file number .nnnnnn.fits
;   H       STRUCT 1st row of fits file (without data,stat)
;   HMAIN   STRUCT pdev main header
;   HSP1    STRUCT pdev sp1 header
;
;   The fits file row header contains all the info for the first row
;(except for the spectral and status data).
;EXAMPLE:
;
;1. get 1 file
;fname='/share/pdata1/pdev/x108.20080530.b0s0g0.00000.fits'
;nsum=masfilesum(fname,sumI)
;
;2. Get all the x108 files under /share/pdata1 (online files) for 30may08
;
;n=masfilelist(junk,fnmI,projid="x108",year=2008,mon=5,day=30,/appbm)
;nsum=masfilesum(junk,sumI,fnmI=fnmI)
;742 files returned..
;
;NOTE:
;   nsum will always equal the number of elements in flist or fnmI. You need
;to check sumI.ok eq 1 to see if the data is ok. This lets you keep track
;of bad files (say with 0 rows).
;-
function masfilesum,flist,sumI,fnmI=fnmI
;
    start=1
    useFnmI= keyword_set(fnmI);
    nfiles=(useFnmI)?n_elements(fnmI):n_elements(flist);
    for i=0,nfiles-1 do begin &$
        masclose,/all &$
        if (useFnmI) then begin
            istat=masopen(junk,desc,fnmI=fnmI[i]) &$
        endif else begin
            istat=masopen(flist[i],desc) &$
        endelse
        if istat ne 0 then begin
            fname=(useFnmI)?fnmI[i].fname:flist[i]
			sumI[i].fname=fname
            print,"  skipping:",fname &$
            continue 
        endif
        istat=masget(desc,b,/hdronly) &$
        if istat ne  1  then begin
			sumI[i].fname=fname
			continue
		endif
        if start then begin &$
            a={$
				ok: 0, $
			 fname: ''  ,$ 
			 fsize: 0LL ,$  ; file size in bytes 
			 nrows   :0L,$
			 dumpRow :0L,$		; at least first row

			 date    :0L,$		; 20080803
			 bm      :0,$
			 band    :0,$     ; 0,1
			 grp     :0,$     ; 0,1
			 num     :0L,$    ; file num

             h       :b.h    ,$ first fits row 
			 hmain   :desc.hmain,$ ; pdev main header
			 hsp1    :desc.hsp1 $  ; pdev sp1 header
             }       
            sumI=replicate(a,nfiles) 
            start=0 
        endif
		mastdim,b.h,nspc=nspc
		fmatch=stregex(desc.filename, $
 ;       date      bm    band    grp      num
"^.*\.([0-9]+)\.b[0-9]s[0-1]g([0-9])\.([0-9]+)\.fits",/extract,/subexpr)
		fst=fstat(desc.lun)

        sumI[i].ok  =1 
        sumI[i].fname =desc.filename
        sumI[i].fsize =fst.size			; file  size in bytes
        sumI[i].nrows =desc.totrows
        sumI[i].dumprow=nspc 			; dump/row at least first row
		sumI[i].date   =long(fmatch[1])
        sumI[i].bm     =fix(desc.hmain.beam)  ; 0..6 for alfa
        sumI[i].band    =fix(desc.hmain.subband) ; 0,1 low hi band
        sumI[i].grp     =fix(fmatch[2])       ; 0,1
        sumI[i].num     =long(fmatch[3])       ; file num
        sumI[i].h     =b.h &$
        sumI[i].hmain =desc.hmain  &$
        sumI[i].hsp1  =desc.hsp1   &$
    endfor
    masclose,/all
    return,nfiles
end
