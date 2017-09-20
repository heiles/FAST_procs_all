;+
;NAME:
;mostrecentfile - find most recentm file
;SYNTAX:stat=mostrecentfile(dir,filemask,newFI,$
;            curFI=curFI,flist=flist,oldest=oldest)
;ARGS:
; dir   : string  directory to search in 
; filemask:string filemask to pass to file_search. this mask is passed
;                 to the ls command.. so glob chars are used.
;                 * any string (including null)
;                 ? 1 char,
;              [..] any char in [],
;                ~usr home dir,
; newFI: {}    new file info found
;
;KEYWORDS:
; curFI:{}        file Info structure. If supplied then find then
;                     the next file after this file.
; oldest:int      if set then return the oldest rather than the
;                 newest file. Use this to find the first file of 
;                 a set.
;RETURNS:
;   stat:         1: found file, -1 no file.
;  newFI: {}      File info structure for file that was found.
;  flist:strarr   list of files found from the ls command.
;DESCRIPTION:
;	Find the most recent file that fits the specifications provided by the 
;user. This routine is normally used for monitoring where you want to
;find the next file automatically. The routine uses ls filename where 
;filename may contain some wildcards.
;Examples for using it.
;1. If monitoring a days worth of files:
;  a. set dir,filemask, and set oldest on return set curFI=newFI
;  b. When ready to move to the next file, pass in curFI=curFI to find the
;     next file.
;2. for online montoring of most recent file do the same as 1. do not set oldest.
;-	
;
function mostrecentfile,dir,filemask,newFI,curFI=curFI,flist=flist,$
            oldest=oldest

    flist=''
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
