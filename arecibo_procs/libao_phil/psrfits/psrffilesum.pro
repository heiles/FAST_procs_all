;+
;NAME:
;psrffilesum - get summary info for psrfits files
;SYNTAX: nsum=psrffilesum(flist,sumI,desc=desc,fnmI=fnmI,list=list)
;
;ARGS:
; flist[n]:strarr filenames for summary. Includes directory.
;KEYWORDS:
;desc   :{}       descriptor returned from psrfopen. If supplied then ignore flist
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
;  FILENAME        STRING    '/share/pdata1/pdev/a2675.20120311.J0651+28.b0s1g0.00000.fits'
;   NEEDSWAP        BYTE         1
;   BYTESROW        LONG           4136556
;   TOTROWS         LONG                85
;   CURROW          LONG                 0
;   BYTEOFFREC1     LONG             28800
;   BYTEOFFNAXIS2   LONG             20400
;   HPRI            STRUCT    psrfits primary header
;   HAOGEN          STRUCT    ao generic header
;   HPDEV           STRUCT    pdev header
;   HSUBINT         STRUCT    psrfits subint header
;   hrow            struct    header from first row
;                             excludes the array info (freq,wts,off,scl,data,stat)
;
;EXAMPLE:
;
;1. get 1 file
;fname='/share/pdata1/pdev/a2675.20120311.B0611+22.b0s1g0.00000.fits'
;nsum=psrffilesum(fname,sumI)
;
;2. Get all the a2675 files under /share/pdata1 (online files) for 11mar2012
;   list a 1 line summary of each file as they are read
;
;n=masfilelist(junk,fnmI,projid="a2675",yymmdd=20120311,/appbm,/psrfits)
;nsum=psrffilesum(junk,sumI,fnmI=fnmI,/list)
;
;NOTE:
;   nsum will always equal the number of elements in flist or fnmI. You need
;to check sumI.ok eq 1 to see if the data is ok. This lets you keep track
;of bad files (say with 0 rows).
;-
function psrffilesum,flist,sumI,fnmI=fnmI,desc=desc,list=list
;
	linecnt=0L
	linesPerHead=60
    useFnmI= keyword_set(fnmI);
	useDesc= keyword_set(desc) 
    nfiles=(useDesc)?1:(useFnmI)?n_elements(fnmI):n_elements(flist);
	icur=0L
    for i=0,nfiles-1 do begin &$
        if not useDesc then psrfclose,/all &$
		if (useDesc) then begin
		   istat=0
		endif else  begin  	
        	if (useFnmI) then begin
            istat=psrfopen(junk,desc,fnmI=fnmI[i]) &$
        	endif else begin
            istat=psrfopen(flist[i],desc) &$
        	endelse
		endelse
        if istat ne 0 then begin
            fname=(useFnmI)?fnmI[i].fname:flist[i]
            print,"  skipping:",fname &$
            continue 
        endif
        istat=psrfget(desc,b,/hdronly,row=1) &$
        if istat ne  1  then begin
            fname=(useDesc)?desc.filename:(useFnmI)?fnmI[i].fname:flist[i]
            print,"skipping:",fname
            continue
        endif
        if icur eq 0 then begin &$
			a={hrow, $
				TSUBINT  :0D,$
   				OFFS_SUB :0D,$
   				LST_SUB  :0D,$ 
   				RA_SUB   :0d,$      
     		    DEC_SUB  :0d,$
                GLON_SUB :0d,$
                GLAT_SUB :0d,$
                FD_ANG   :0.,$
                POS_ANG  :0.,$
                PAR_ANG  :0.,$
                TEL_AZ   :0.,$
                TEL_ZEN  :0.}


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
			 src     :'',$
			 cfr     :0D,$    ; Mhz topocentric freq dat_freq[nchan/2]
			 bw      :0D,$    ; Mhz

             hpri    :desc.hpri,$  ; psrfits primary header
             haogen  :desc.haogen,$ ;ao generic header
             hpdev   :desc.haogen,$ ;pdev  header
             hsubint :desc.hsubint,$ ; psrfits subint
			 hrow1   :{hrow} }       ; hdr from 1st row, no arrays.
            sumI=replicate(a,nfiles) 
        endif
        nspc=desc.hsubint.nsblk
        fmatch=stregex(desc.filename, $
 ; proj  date    src    bm    band    grp      num
;"^.*\.([0-9]+)\.[^.]+\.b[0-9]s[0-1]g([0-9])\.([0-9]+)\.fits",/extract,/subexpr)
".*/([^.]*)\.([0-9]+)\.([^.]*)\.b([0-9])s([0-1])g([0-9])\.([0-9]+)\.fits",/extract,/subexpr)
        fst=fstat(desc.lun)

		projId=fmatch[1]
        sumI[icur].ok  =1 
        sumI[icur].fname =desc.filename
        sumI[icur].fsize =fst.size         ; file  size in bytes
        sumI[icur].nrows =desc.totrows
        sumI[icur].dumprow=nspc            ; dump/row at least first row
        sumI[icur].date   =long(fmatch[2])
        sumI[icur].src    =(fmatch[3])
        sumI[icur].bm     =long(fmatch[4])
        sumI[icur].band   =long(fmatch[5])
        sumI[icur].grp    =fix(fmatch[6])       ; 0,1
        sumI[icur].num    =long(fmatch[7])       ; file num
		sumI[icur].cfr    =b.dat_freq[desc.hsubint.nchan/2]
		sumI[icur].bw     =desc.hsubint.chan_bw*desc.hsubint.nchan
        sumI[icur].hpri   =desc.hpri
        sumI[icur].haogen =desc.haogen   ;ao generic header
        sumI[icur].hpdev  =desc.haogen   ;pdev  header
        sumI[icur].hsubint=desc.hsubint  ; psrfits subint
		hrow1={hrow}
		struct_assign,b,hrow1
	    sumI[icur].hrow1  =hrow1

		if keyword_set(list) then begin
			if lineCnt mod linesPerhead eq 0 then begin
; .. include space for sign of bandwidth
				print,$
" Proj  Fnum   BSG        SOURCE      SCAN     RA       DEC C   nSpc POL Chn    PatNm TopFrq   Bw   RCV"
;aaaaaxnnnnnxb0s0g0xaaaaaaaaaaaaxdddddddddxhhmmss.sxmddmmssxaxddddddxddxddddxaaaaaaaaxffff.fxsfff.fxaaaaaaaa
;  a5   i5     a6           a12       i9     f8.1     i7   a1     i6 i2   i4   a8       f6.1 f6.1 a 
			endif
				ll=strsplit(desc.hpri.stt_crd1,":.",/extract)
				rahms=ll[0]+ll[1]+ ll[2] + "." + strmid(ll[3],0,1)
				ll=strsplit(desc.hpri.stt_crd2,":.",/extract)
				decdms=ll[0]+ll[1]+ ll[2] 
 			    bsg=string(format='("b",i1,"s",i1,"g",i1)',sumI[icur].bm,sumI[icur].band,sumI[icur].grp)
    				 print,format=$
  '(a5,1x,i5,1x,a6,1x,a12,1x,i9,1x,a8,1x,a7,1x,a1,1x,i6," ",i2," ",i4," ",a8," ",f6.1,1x,f6.1,1x,a)',$
 		 projId,sumI[icur].num,bsg,sumI[icur].hpri.src_name,sumI[icur].haogen.scan_id,rahms,decdms,"J",$
	    sumI[icur].nrows*sumI[icur].dumprow,sumI[icur].hsubint.npol,sumI[icur].hsubint.nchan,$
 		sumI[icur].haogen.obsmode,sumI[icur].cfr,sumI[icur].bw,$
 		sumI[icur].hpri.frontend
 				linecnt++
 		endif
		icur++
    endfor
    if not keyword_set(desc) then  psrfclose,/all
	if icur ne nfiles then begin
		sumI=(icur eq 0)? '':sumI[0:icur-1]
	endif
    return,icur
end
