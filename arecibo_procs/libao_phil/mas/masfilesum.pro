;+
;NAME:
;masfilesum - get summary info for files
;SYNTAX: nsum=masfilesum(flist,sumI,desc=desc,fnmI=fnmI,list=list)
;
;ARGS:
; flist[n]:strarr filenames for summary. Includes directory.
;KEYWORDS:
;desc   :{}       descriptor returned from masopen. If supplied then ignore flist
;                 and use desc as the file to look at.
;fnmI[n]:{}       structure returned by masfilelist. If this keyword is
;                 present then ignore flist and use fnmI for the files
;                 to use.
;list   :         if set then output oneline summary to stdout of file
;RETURNS:
;    nsum: long    number of summaries we return. Don't count files that had trouble being read
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
function masfilesum,flist,sumI,fnmI=fnmI,desc=desc,list=list
;
	linecnt=0L
	linesPerHead=60
    useFnmI= keyword_set(fnmI);
	useDesc= keyword_set(desc) 
    nfiles=(useDesc)?1:(useFnmI)?n_elements(fnmI):n_elements(flist);
	icur=0L
    for i=0,nfiles-1 do begin &$
        if not useDesc then masclose,/all &$
		if (useDesc) then begin
		   istat=0
		endif else  begin  	
        	if (useFnmI) then begin
            istat=masopen(junk,desc,fnmI=fnmI[i]) &$
        	endif else begin
            istat=masopen(flist[i],desc) &$
        	endelse
		endelse
        if istat ne 0 then begin
            fname=(useFnmI)?fnmI[i].fname:flist[i]
            print,"  skipping:",fname &$
            continue 
        endif
        istat=masget(desc,b,/hdronly,row=1) &$
        if istat ne  1  then begin
            fname=(useDesc)?desc.filename:(useFnmI)?fnmI[i].fname:flist[i]
            print,"skipping:",fname
            continue
        endif
        if icur eq 0 then begin &$
            a={$
                ok: 0, $
             fname: ''  ,$ 
             fsize: 0LL ,$  ; file size in bytes 
             nrows   :0L,$
             dumpRow :0L,$      ; at least first row

             date    :0L,$      ; 20080803
             bm      :0,$
             band    :0,$     ; 0,1
             grp     :0,$     ; 0,1
             num     :0L,$    ; file num

             h       :b.h    ,$ first fits row 
             hmain   :desc.hmain,$ ; pdev main header
             hsp1    :desc.hsp1 $  ; pdev sp1 header
             }       
            sumI=replicate(a,nfiles) 
        endif
        mastdim,b.h,nspc=nspc
        fmatch=stregex(desc.filename, $
 ;       date      bm    band    grp      num
;"^.*\.([0-9]+)\.b[0-9]s[0-1]g([0-9])\.([0-9]+)\.fits",/extract,/subexpr)
".*/([^.]*)\.([0-9]+)\.b[0-9]s[0-1]g([0-9])\.([0-9]+)\.fits",/extract,/subexpr)
        fst=fstat(desc.lun)

		projId=fmatch[1]
        sumI[icur].ok  =1 
        sumI[icur].fname =desc.filename
        sumI[icur].fsize =fst.size         ; file  size in bytes
        sumI[icur].nrows =desc.totrows
        sumI[icur].dumprow=nspc            ; dump/row at least first row
        sumI[icur].date   =long(fmatch[2])
        sumI[icur].bm     =fix(desc.hmain.beam)  ; 0..6 for alfa
        sumI[icur].band    =fix(desc.hmain.subband) ; 0,1 low hi band
        sumI[icur].grp     =fix(fmatch[3])       ; 0,1
        sumI[icur].num     =long(fmatch[4])       ; file num
        sumI[icur].h     =b.h &$
        sumI[icur].hmain =desc.hmain  &$
        sumI[icur].hsp1  =desc.hsp1   &$
		if keyword_set(list) then begin
			if lineCnt mod linesPerhead eq 0 then begin
				print,$
" Proj  Fnum   BSG        SOURCE      SCAN     RA       DEC C   nSpc POL Chn    PatNm TopFrq  Bw   RCV"
;aaaaaxnnnnnxb0s0g0xaaaaaaaaaaaaxdddddddddxhhmmss.sxmddmmssxaxddddddxddxddddxaaaaaaaaxffff.fxfff.fxaaaaaaaaa
;  a5   i5     a6           a12       i9     f8.1     i7   a1     i6 i2   i4   a8       f6.1 f5.1 a 
			endif
				 ll=fisecmidhms3(b.h.crval2/360D*86400.,h,m,s,/float) ; to time secs
     	 		rahms=h*10000L+m*100L +s
         		ll=fisecmidhms3(b.h.crval3*3600D,d,m,s,/float)       ; to arc secs
         		 decdms=d*10000L+m*100L +s
			    bsg=string(format='("b",i1,"s",i1,"g",i1)',sumI[icur].bm,sumI[icur].band,sumI[icur].grp)
   				 print,format=$
 '(a5,1x,i5,1x,a6,1x,a12,1x,i9,1x,f8.1,1x,i7,1x,a1,1x,i6," ",i2," ",i4," ",a8," ",f6.1,1x,f5.1,1x,a)',$
		 projId,sumI[icur].num,bsg,b.h.object, b.h.scan_id,rahms,long(decdms),"J", desc.totrows*b.ndump,$
 		b.npol,b.nchan,b.h.obsmode,b.h.crval1*1e-6,b.h.bandwid*1e-6,$
		 b.h.frontend 
				linecnt++
		endif
		icur++
    endfor
    if not keyword_set(desc) then  masclose,/all
	if icur ne nfiles then begin
		sumI=(icur eq 0)? '':sumI[0:icur-1]
	endif
    return,icur
end
