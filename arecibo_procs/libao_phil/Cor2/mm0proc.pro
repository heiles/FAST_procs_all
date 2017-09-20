;+
;NAME:
;mm0proc - do mueller 0 processing of data in a file.
;
;SYNTAX: npat=mm0proc(filename,mm,skycor=skycor,astro=astro,$
;        noplot=noplot,noprint=noprint,keywait=keywait,cumcorr=cumcorr,$
;        board=board,rcvnum=rcvnum,slinp=slinp,no_mcorr=no_mcorr)
;ARGS:
;   filename:   string. name of file with correlator data.
;
;RETURNS:
;   mm[npat]:   {mueller} array of structs with data (1 per pattern)
;   npat    :   long      number of patterns returned
;
;KEYWORDS:
;   skycor  :    int      default is to do the sky correction. skycor=0
;                         will not do the sky correction.
;   astro   :    int      default is to do the astronomical correction.
;                         astro=0 will not do it.
;   noplot  :    int      if set then do not plot out the spectra. default
;                         is to plot.
;   noprint :    int      if set then do not plot out the spectra. default
;   noplot  :    int      if set then do not print out the results as you
;                         to along. default is to print them out.
;   keywait :    int      if set then wait for a keystroke after every pattern.
;   cumcorr :    int      if set then do the cum correction to excise rfi
;   board   :    int      0 to 3. If set then just process this correlator
;                         board. The default is to process 4 boards.
;   tcalx[4]:   float     polA cal values to use for the 4 boards.
;                         If not supplied then look them up.
;   tcaly[4]:   float     polB cal values to use for the 4 boards.
;                         If not supplied then look them up.
;   rcvnum  :   int       rcvr number to process.Default is process all
;                         receivers.
;   slinp[] :  {sl}       scan list to use if user has already scaned file
;                         with getsl. If slinp=null and rcvnum != null then
;                         the scanned sl will be returned in slinp.
;   no_mcorr:             if set then no mueller correction is done 
;                         (independent of skycor,astro,etc).
;
;DESCRIPTION:
;   mm0proc will do the mueller0 processing of all of the calibration patterns 
;in a file. It will return the results (mm) as an array of {mueller} structures
;(see mmrestore for a description of whats in the structure).
;   If the user specifies the board keyword (0 to 3) then only that
;board will be processed. By default all 4 boards are processed (a feature/bug
;is that integrations using less then 4 boards still loop through all
;the board numbers.. the data is ok, it just takes a little longer).
;
;   When you are done with this routine you can save the data as 
;a save file in idl..
;   save,mm,filenamae=' xxxx' 
;
;   When starting idl you need to source carl's startup routines:
;@~heiles/allcal/idlprocs/xxx/start_cross3.idl 
;or make your IDL_STARTUP environment variable point there.
;
;SEE ALSO:
;mmrestore, mm0proclist
;-
;05jul01 - added common crossparams and tcalxx_board,tcalyy_board
;
function  mm0proc,filename,mm,skycor=skycor,astro=astro,noplot=noplot,$
            noprint=noprint,keywait=keywait,cumcorr=cumcorr,board=board,$
            tcalx=tcalx,tcaly=tcaly,rcvnum=rcvnum,slinp=slinp,no_mcorr=no_mcorr

    COMMON cross3_gencal
    COMMON hdrdata
    COMMON crossparams

    on_error,1
    m_skycorr=1
    m_astro  =1
    noplott  =1
    noprintt =1
    keywaitt =0
    brdstart=0
    brdend  =3
    if n_elements(skycor) ne 0 then m_skycorr=skycor
    if n_elements(astro)  ne 0 then m_astro  =astro
    if (n_elements( noplot)  ne 0) then noplott=noplot
    if (n_elements( noprint) ne 0) then noprintt=noprint
    if (n_elements( keywait) ne 0) then keywaitt=keywait
    if (n_elements( cumcorr) eq 0) then cumcorr=0
    if (n_elements( tcalx )  eq 0) then tcalx=fltarr(4)  -1.
    if (n_elements( tcaly )  eq 0) then tcaly=fltarr(4)  -1.
    if (n_elements( rcvnum ) eq 0) then rcvnum=0
    if (n_elements(board) ne 0) then begin
        brdstart=board
        brdend  =board
    endif
    tcalxx_board=tcalx
    tcalyy_board=tcaly

    pos=strpos( filename, '.')
    if pos eq -1 then begin             ; online
        ext='.online'
    endif else begin
        ext=strmid( filename, strpos( filename, '.'))
    endelse
    openr, lun, filename, /get_lun
;
;   if we want only 1 receiver.. create scan list  for direct access
;
    if rcvnum ne 0 then begin
        if (not keyword_set(slinp)) then  begin
            print,'scanning file for direct access:'+filename
            sl=getsl(lun)
            slinp=sl
        endif else begin
            sl=slinp
        endelse
;
;       all cal ons for this reciever
;
        indlist=where((sl.rcvnum eq rcvnum) and (sl.rectype eq 1),j)
;
;       make sure we have at least 1 pattern..each pattern 6 scans
;
        if (j eq 0) then goto,nodata
;       last set has 6 scans ??
        if ((indlist[j-1] + 5) gt (n_elements(sl)-1)) then  begin 
                if (j lt 2) then goto , nodata 
                indlist=indlist[0:j-2] 
        endif
;
;       make sure next scan is cal off and then 240 recs
;
        ind=where((sl[indlist+1].rectype eq 2 ) and $
                  (sl[indlist+2].numrecs eq 60) and $
                  (sl[indlist+3].numrecs eq 60) and $
                  (sl[indlist+4].numrecs eq 60) and $
                  (sl[indlist+5].numrecs eq 60))
        indlist=indlist[ind]
        numind=n_elements(indlist)
        print,'scanning file completed. found:',numind,' patterns to process'
;       stop
    endif

;
    nrc=0
;DEFINE THE ARRAY OF FILE NAMES FOR THE RECEIVERS..

    nterms=6
    for brdnum=brdstart,brdend do begin
        rew, lun
        last  =0
        !quiet=1
        ind=0
        repeat begin
            if (rcvnum ne 0) then begin ; do just 1 receiver
; print,'ind,scan,pos:',ind,sl[ind].scan,sl[ind].bytepos
                point_lun,lun,sl[indlist[ind]].bytepos
                ind=ind+1
                if ind ge numind then last=1
            endif
        cross3_gencal, brdnum,  stokesc1, b_0, b_1, b_2, b_3, returnstat, $
            /sequential, npatterns = 1, $
            noplot=noplott, keywait=keywaitt, cumcorr=cumcorr
        if (returnstat eq 0) then goto, finished  
;       print,"returnstat:",returnstat
;
;   pjp30ju01 .. add src flux
;
        srcname=string(b_0[0].b1.h.proc.srcname)
        cfr    =b_0[0].b1.h.dop.freqbcrest + b_0[0].b1.h.dop.freqoffsets[brdnum]
        sourceflux=fluxsrc(srcname,cfr)
        if (sourceflux le 0.) then sourceflux=-1.
;        print,srcname,' brd:',brdnum,' cfr:',cfr,' flux:',sourceflux
        if (returnstat eq 1) then begin
            mmhdrdef_allcal, nterms, b_0, b_1, b_2, b_3, brdnum, stokesc1, $
            azoffset, zaoffset, totoffset, stokesoffset_cont, stokesoffset, $
            stripfit, sigstripfit, tempfits, b2dfit,no_mcorr=no_mcorr, $
            plotyes=1, no1dplot=0, show=1, m_skycorr=m_skycorr, m_astro=m_astro
            nrc=nrc+1
        endif else  begin
            print, 'THIS PATTERN NOT SAVED...PATTERN REDUCTION UNSUCCESSFUL!!',$
                string(7b)
        endelse
        !quiet=0
        if (keywaitt eq 1) then begin
            print, 'hit a key to continue...'
            rwait = get_kbrd(1)
        endif

finished:

        endrep until ((returnstat eq 0) or (last eq 1))
    endfor
;
;   now store data in mm array..
;
    free_lun, lun
    mm=mmtostr (/norestore,b2dcfs=b2dcfs,hdrscan=hdrscan,strp_cfs=strp_cfs,$
                hdrsrcname=hdrsrcname,hdr1info=hdr1info,hdr2info=hdr2info)
;   see if they were all bad.. this is just mm=''
    if (size(mm))[0] eq 0 then goto,nodata
    return,n_elements(mm)
nodata: 
    print,'no scans for this receiver'
    free_lun,lun
    mm=''
    return,0
end
