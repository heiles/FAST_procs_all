;+
;NAME:
;mm0proclist - do mueller 0 processing for a set of data files
;
;SYNTAX: npat=mm0proclist(listfile,mm,maxpat=maxpat,skycor=skycor,astro=astro,$
;                         noplot=noplot,noprint=noprint,keywait=keywait,$
;                         cumcorr=cumcorr,board=board,rcvnum=rcvnum,fnameind=fnameind)
;
;ARGS:
;   listfile: string. filename holding names of correlator files 
;                     (one per line). semi-colon as the first char is a comment.

;RETURNS:
;   mm[npat]: {mueller} array of structs with data (1 per pattern)
;   npat    : long      number of patterns returned
;
;KEYWORDS:
;   maxpat  : long      maximum number of patterns to process. The default
;                       is 1000. It will pre-allocate an array of structures
;                       of this size to hold the data.
;   fnameind: int       index of word in line for filename (count from 0)
;                       default is the first word of line. words are separated by
;                       whitespace.
;   extra   :           for other keywords see mm0proc
;DESCRIPTION:
;   Call mm0proc for every filename in listfile. Return all of the 
;data in one array of structures. An example of the listfile is:
;
;;  a comment
;/share/olcor/calfile.19mar01.a1400.1
;/share/olcor/calfile.20apr01.a1446.1
;/share/olcor/calfile.20apr01.a1489.1
;/share/olcor/calfile.20mar01.a1389.1
;
;It would process all 4 files and return the data in mm.
;
;-
function  mm0proclist,listfile,mmall,maxpat=maxpat,fnameind=fnameind,_extra=_e

    on_error,1
    if n_elements(maxpat) eq 0 then maxpat=2000L
    if n_elements(fnameind) eq 0 then fnameind=0
    mmall=replicate({mueller},maxpat)
    cnt=0
    on_ioerror,done
    lun1=-1
    openr,lun1,listfile,/get_lun
    line=' '
    while 1 do begin
        readf,lun1,line    
        if strmid(line,0,1) ne ';' then  begin
            filename=strsplit(line,' ',/extract)
            print,'processing file:',filename[fnameind]
            npat=mm0proc(filename[fnameind],mm,_extra=_e)
            if npat+cnt gt maxpat then npat=maxpat-cnt
            if npat gt 0 then begin
               mmall(cnt:cnt+npat-1)=mm[0:npat-1]
               mm=''
               cnt=cnt+npat
               if cnt ge maxpat then begin
                    print,'hit max number of patterns:',maxpat
                    goto,done
               endif
             endif
        endif
    endwhile
done: 
    if lun1 ne -1 then free_lun,lun1
    if cnt lt maxpat then mmall=temporary(mmall[0:cnt-1])
    return,cnt
end
