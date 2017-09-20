;
; find all wappfiles below a directory
;
if keyword_set(lundir)  then begin
   if (lundir gt 0) then free_lun,lundir
endif
openr,lundir,'/home/phil/idl/wapp/wappdir.dattest',/get_lun
inpline=''
rew,lundir
ntot=0L
maxfiles=10000L
listall=strarr(maxfiles)
print,'scanning discs:'
while not eof(lundir) do begin &$
    readf,lundir,inpline &$
    if strmid(inpline,0,1) ne ';' then begin &$
    	dir=strtrim(inpline,2) &$
;
;   command for after added wappn to filenamefor ver
;
;cmd='find ' + dir + ' -follow  -name "*\.wapp*" -print'
;
;   \.5dddd\.ddd*  where d is a digit 0..9
; below will remove all ending chars that are not a 
;
    	cmd ='find ' + dir + $
    ' -name "*\.5[0-9][0-9][0-9][0-9]\.[0-9][0-9][0-9]*" -print -follow' &$
    	spawn,cmd,list &$
;
;	remove filenames that don't end in digit
;   grab last char, see if digit
;
		last=strmid(list,0,1,/reverse) &$
		ok=strmatch(last,'[0-9]') &$
		ind=where(ok eq 1,count) &$
		if count gt 0 then begin &$
    		listall[ntot:ntot+count-1]=list[ind] &$
    		ntot=count+ntot &$
    		print,'nfiles,ntot:',count,ntot &$
		endif &$
    endif &$
endwhile
listall=listall[0:ntot-1]
free_lun,lundir
;   
goodfile=intarr(ntot)
on_ioerror,next
nfound=0
print,'reading headers'
for i=0L,ntot-1 do begin &$
   lun=-1 &$
    openr,lun,listAll[i],/get_lun &$
    istat=wappgethdr(lun,hdr) &$
    if istat eq 1 then begin &$
        if nfound eq 0 then hdrAr=replicate(hdr,ntot) &$
        hdrAr[nfound]=hdr &$
        nfound=nfound+1 &$
        goodfile[i]=1 &$
    endif else begin &$
		lab=string(format=$
'("bad..ind:",i5," ntot:",i5," ",a)',i,nfound,listAll[i])
        print,lab
    endelse &$
next: &$
    if lun ne -1 then free_lun,lun &$
endfor
if nfound gt 0 then begin &$
    ind=where(goodfile eq 1,count) &$
    hdrar=hdrar[ind] &$
    flist=listAll[ind] &$
endif else begin &$
    hdrar='' &$
    flist='' &$
endelse
daterun=systime()
;save,flist,hdrar,daterun,file='/share/megs/phil/x101/archive/wapp/wapphdrs.sav'
end
