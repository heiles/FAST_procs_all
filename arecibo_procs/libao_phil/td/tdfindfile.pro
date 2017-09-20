;+
;NAME:
;tdfindfile - find the locations of a tiedown file.
;SYNTAX: istat=tdfindfile(yymmdd,fullname)
;ARGS:
;   yymmdd: long    Date to search for. YY is the last two digits of the year.
;RETURNS:
;   istat:  int     1 -found it, 0 did not find it
; fullname: string  if found then this is the full name of the file
;                   (path name and basename)
;
;DESCRIPTION:
;   Search the various online directories for the location of
;a tiedown file. Return 1 if it is found with the name in the fullname
;variable. Return 0 if it is not found.
;
;-
function tdfindfile,yymmdd,fullname
;
    bkupdir='/share/phil/bkup/tie/'
    bkupdirM=bkupdir + string(format='(i4.4,"/")',yymmdd/100L)
    dirList=['/share/obs2/tie/log/',$
             bkupdirM,$
             bkupdir]
    bname=string(format='("tie",i6.6,".dat")',yymmdd)
    fullname=''
    for i=0,n_elements(dirlist)-1 do begin
        if file_test(dirList[i]+bname) then begin
            fullname=dirList[i]+bname
            return,1
        endif
    endfor
    return,0
end
