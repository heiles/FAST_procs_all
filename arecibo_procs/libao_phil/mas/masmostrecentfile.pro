;+
;NAME:
;masmostrecentfile - find most recent mas file
;SYNTAX:stat=masmostrecentfile(projId,ldate,bsg,lnum,baseDir,newFI,$
;            curFI=curFI,flist=flist,oldest=oldest,dirI=dirI,noappbm=noappbm,$
;            src=src,psrfits=psrfits)
;ARGS:
; projid: string  project to search for. "*" for any project. Project
;                 if the first part of the filename (projId.yyyymmdd.xxx)
; ldate : string  date to search for. Format is: yyyymmdd. Use "*" for any
;                 date.
;    bsg: string  BeamSubbandGroup to search for. eg:
;                 b0s0g0 for beam0, subband0, group 0.
;   lnum: string  file number to search for. Should be 5 digits eg: 00100.
;                 Use "*" for any file number.
;KEYWORDS:
; curFI:{}        file Info structure. If supplied then file the next file after
;                 this file.
; oldest:int      if set then return the oldest rather than the newest file.
;                 Use this to find the first file of a day.
; dirI:strarr[2]  If supplied then this specifies the prefix and suffix for the
;                 directories to search.  The prefix is the directory name prior to
;                 to directory number and the suffix is the directory path
;                 following the number. The default is:
;                 dirI[0]='/share/pdata', dirI[1]="/pdev/"
; noappbm:        if set then dirI[0],dirI[1] do not have a beam number 
;                 between them. use for data in /share/pdata/pdev
; src: ''         if supplied then require this source name (for psrfits)
;psrfits:         if set then search for psrfits files that have a srcname
;RETURNS:
;   stat:         1: found file, -1 no file.
; basdir: string  base dir for files we searched for: eg
;                 /share/pdata1/pdev/
;  newFI: {}      File info structure for file that was found.
;  flist:strarr   list of files found from the ls command.
;DESCRIPTION:
;	Find the most recent file that fits the specifications provided by the 
;user. This routine is normally used for monitoring where you want to
;find the next file automatically. The routine uses ls filename where 
;filename may contain some wildcards.
;Examples for using it.
;1. If monitoring a days worth of files:
;  a. set projid,ldate,bsg, lnum=*, and set oldest
;     on return set curFI=newFI
;  b. When ready to move to the next file, pass in curFI=curFI to find the
;     next file.
;2. for online montoring of most recent file do the same as 1. do not set oldest.
;-	
;
function masmostrecentfile,projid,ldate,bsg,lnum,newFI,curFI=curFI,flist=flist,$
            oldest=oldest,dirI=dirI,psrfits=psrfits,src=src,noappbm=noappbm

	if n_elements(noappbm) eq 0  then noappbm=0
	if (n_elements(dirI) eq 2) then begin
		dirPre=dirI[0]
		dirPost=dirI[1]
		if (strmid(dirPost,0,1,/reverse_offset) ne "/" ) then dirPost+="/"
	endif else begin
		dirPre ="/share/pdata"
		dirPost="/pdev/"
	endelse
    flist=''
    a=stregex(bsg,'b([0-9])s[0-1]g([0-1])',/ext,/sub)
    bm =fix(a[1])
    grp=fix(a[2])
    pdataNum=(grp eq 1)?7 + (bm + 1):(bm+1)
    
	if keyword_set(noappbm) then begin
    	basDir= dirPre+dirPost
	endif else begin
    basDir=(pdataNum lt 10)$
        ?string(format='(a,i1,a)',dirPre,pdataNum,dirPost)$
        :string(format='(a,i2,a)',dirPre,pdataNum,dirPost)
	endelse
	if keyword_set(psrfits) then begin
		lsrc=(n_elements(src) gt 0)?src:'*'
   	    filematch=basDir + projid + "." + ldate + "." + lsrc + "." + bsg + "." + lnum + ".fits"
	endif else begin
    	filematch=basDir + projid + "." + ldate + "." + bsg + "." + lnum + ".fits"
	endelse
    cmd="ls -1t " + filematch
    spawn,cmd,flist,errlist
    if flist[0] eq '' then return,-1  ; no files
    ii=0
    if n_elements(curFI) gt 0 then begin
        fname=curFI.fdir + curFI.fbase
        ii=where(flist eq fname,cnt)
        if cnt eq 0 then return,-1
        ii=ii[0]
        ii=(ii eq 0)?ii:ii-1
    endif else begin
        if (keyword_set(oldest)) then begin
            ii=n_elements(flist)-1
        endif
    endelse
;   
    curFile=flist[ii]
    if (keyword_set(psrfits)) then begin
;     proj     date    src     bsg               num
        a=stregex(curFile,$
"(.*/)([^.]+).([0-9]+).(.*).(b[0-6]s[0-1]g[0-1]).([0-9]+)",/sub,/ext)
    	newFI={$
       		 fdir: a[1],$
       		fbase: a[2]+'.'+a[3]+'.'+a[4]+'.'+a[5]+ '.' + a[6]+'.fits',$
       		proj : a[2],$
       		ldate: a[3],$
			  src: a[4],$
         	  bsg: a[5],$
        	 lnum: a[6]}
    endif else begin
;        a=stregex(curFile,"(.*/)([^.]+).([0-9]+).([^.]+).([0-9]+)",/sub,/ext)
;                                proj    date     bsg     lnum
        a=stregex(curFile,"(.*/)([^.]+).([0-9]+).(b[0-6]s[0-1]g[0-1]).([0-9]+)",/sub,/ext)
    	newFI={$
       		 fdir: a[1],$
       		fbase: a[2]+'.'+a[3]+'.'+a[4]+'.'+a[5]+'.fits',$
       		proj : a[2],$
       		ldate: a[3],$
			  src: ''  ,$
         	  bsg: a[4],$
        	 lnum: a[5]}
	endelse
    return,1
end
