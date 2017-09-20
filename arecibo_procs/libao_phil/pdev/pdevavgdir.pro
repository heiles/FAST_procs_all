;+
;NAME:
;pdevavgdir - Avg all pdev files in an array of dir.
;SYNTAX: pdevavgdir,dirAr,skyCfr,lo2Off,savDir,verb=verb
;ARGS:
;   dirAr[]: strarr array of directory names to search. The names should
;                   include the trailing /.
;   skyCfr : float  Mhz. sky center frequency Mhz for all the files.
;   lo2Off : float  Mhz. The lo2 offset for the two bands. Use a single
;                        positive number.
;   savDir : string Save file directory where the accumualated save files are
;                   written.
;RETURNS:
;           A save file is written for each .pdev file found. It contains:
;   freq[nchan] frequency array
;   nrecsTot: number of records averaged
;   b       : {} structure holding averaged data
;   skycfr  :    sky center frequency
;   descSav :    the descriptor returned from pdevopen(). This includes
;                the initial file header.
;DESCRIPTION:
; avgerage all the .pdev files in the requested directories.
; save the averages in the savDir directories.
;-
pro pdevavgdir,dirAr,skycfr,lo2Off,savDir,verb=verb
;
; loop over directories;
;
for idir=0,n_elements(dirAr)-1 do begin &$
    dir=dirAr[idir] &$
    flist=file_search(dir,"*.pdev") &$
    print,'files in '+ dir + ':'+ flist &$
    nfiles=n_elements(flist)
    for ifile=0,nfiles-1 do begin
        file=flist[ifile]
        a=stregex(file,'.*/(.*)\.pdev',/extract,/sub)
        savNm=a[1]+'.sav'
        istat=pdevopen(file,desc)
        if istat ne 0 then begin
           print,'not a valid start of obs:',file
           free_lun,desc.lun
           continue
        endif
        nrecs=desc.hdev.nblksdumped
        print,'start '+file + ' nrecs:'+string(nrecs)
        nRecsTot=pdevavg(desc,nrecs,b,rec=1,verb=verb)
        pdevplot,b
        freq=pdevfreq(desc,skycfr=skycfr,lo2off=lo2off)
        descSav=desc
        save,freq,nrecsTot,b,lo2off,skycfr,descSav,file=savDir+savNm
        free_lun,desc.lun
    endfor
endfor
return
end
