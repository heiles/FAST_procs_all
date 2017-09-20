;+
;NAME:
;mmprocherb - process 'beetle' scans 2dfit by channel
;
;SYNTAX:ntot=mmprocherb,corfile,scndata,$
;          mmInfo_arr,hb_arr,beamin_arr,beamout_arr,mmCmp_arr,mmCmpChn_arr,$
;          sl=sl,retsl=retsl,dirsave=dirsave,dirplot=dirplot,polBad=polBad,$
;          mminfo_ArrChn=mminfo_arrChn,han=han,chnrng=chnrng,$
;          tcalxx_board=tcalxx_board,tcalyy_board=tcalyy_board,$    
;          board=board,rcvnam=rcvnam,sourcename=sourcename,npatterns=npatterns,$
;          m_rcvrcorr=m_rcvrcorr,m_skycorr=m_skycorr,m_astro=m_astro,$ 
;          mm_pro_user=mm_pro_user,$
;          phaseplot=phaseplot,plot1d=plot1d,plot2d=plot2d,$
;          print1d=print1d,print2d=print2d,srcprint=srcprint,
;          samemm0=savemm0,onlymm4=onlymm4,$
;          mm4=mm4, plt1yes=plt1yes,ps1yes=ps1yes,byChnl=byChnl,savemm4=savemm4,
;          check=check,negate_q=negate_q,m7=m7,plt0yes=plt0yes,keywait=keywait
; ------------------------------------------------------------------------=-
;ARGS:
;   corfile: name of correlator file to process path and filename.
;   scndata: {scndata} information that parameterizes how scan was done. 
;                      This is set by @mm0init
; ------------------------------------------------------------------------=-
;RETURNS:
;             ntot:long The number of beam fits done. For each pattern used
;                       there will be a beamfit for each board.
; mmInfo_arr[ntot]:{mueller} hold src info, fit info for each fit.
;   hb_arr[4,ntot]:{hdr} for each fit done, the hdr from the first point of 
;                        each of the 4 strips.
; beamin_arr[ntot]:{beaminput} input for 2d beamfit (output of 1s fits)
;beamout_arr[ntot]:{mmoutput}  output of 2d beamfit.
;mmCmp_arr[ntot]:{muellerparams_carl}  if mm4 keyword set, then the
;                        computed mueller matrices are returned here.
;mmCmpChn_arr[128,ntot]:{muellerparams_carl}  if mm4 keyword set and /byChnl
;                        keyword set then this has the mueller matrices by
;                        frequency channel.
;          retsl[]:{sl}  Return the scanlist from scanning the file.
;                        If you reprocess the file, pass this in with sl=retsl
;DEFINITIONS:
;   The structures are defined in the file:
;  aodefdir() + 'spider/pro/mm0/hdrMueller.h
;It is sourced via the @mm0init call.
;The  file also loads the structure {scndata} with the parameterization
;of the pattern.
; ------------------------------------------------------------------------=-
;KEYWORDS:
;   ------------------------
;   GENERAL
;   ------------------------
;   tcalxx_board[4]:float if negative then lookup cal values. if positive
;                   then use these values for polA.brd 0 to 3.
;   tcalyy_board[4]:float if negative then lookup cal values. if positive
;                   then use these values for polB
;     sl[]:{sl}     scanlist to use. Pass this in if you have already scanned 
;                   the file.
;  dirsave:string   Place the save files in this directory. The default is 
;                   the current directory you are running from
;  dirplot:string   Place any plotfiles in this directory. The default is 
;                   the current directory you are running from
;  polBad: int      0--> polA bad, 1--> polB bad. replace bad pol with other.
;                   implies stokesQ=0, u,v junk
;   ------------------------
;   LIMIT THE DATA TO PROCESS: default is all the scans
;   ------------------------
;    board: int     0..3 only process this board. The default is toprocess all
;                   of the boards.
;   rcvnam: string only process this receiver. The default is to process
;                   all receivers. The rcvr names are:
;                327,430,610,lbw,lbn,sbw,sbh,cb,xb,lbwifw,lbnifw,430ch,chlb,
;                and sb750
;sourcname[]: string  array of source names to process. If not provided then
;                do all of the sources.
;npatterns: long   if provided, then only process this many patterns
;                     before returning. The default is to process all that 
;                     match the above criteria.
;   ------------------------
;   MUELLER CORRECTION KEYWORDS:
;   ------------------------
; m_rcvrcorr:       if set, correct for rcvr,iflo. Set this if you want to
;                   get mm-corrected data. If you want to check to see how well 
;                   a mm matrix is applied, set this and don't set m_skycorr
;                   and m_astro; then solve for the mm parametrs. they should 
;                   be zero.
;  m_skycorr:       if set, corrects for sky parallactic rotation. Normally
;                   you set this when correcting data, and don't set it when
;                   computing new matrices.
;    m_astro:       if set, corrects electronics to astronomical position
;                   angle and stokes V definition. The astronomical angle
;                   rotation is not measured for all feeds.
;mm_pro_user:string Name of alternate routine to provide mueller matrix
;                   parameters. eg for lbw:mmp_lbw_08sep00_nocalcorr
;
;   ------------------------
;   PLOTTING/PRINTING KEYWORDS:
;   ------------------------
;  phaseplot:       if set then make phase vs freq plots for cal and source.
;     plot1d:       if set then plot 1d strip fits on the screen.
;     plot2d:       if set then plot 2d beam image fits on the screen.
;    print1d:       if set then print 1d  fits on screen.
;    print2d:       if set then print 2d  fits on screen.
;   ------------------------
;   WHEN COMPUTING THE MUELLER MATRIX:
;   ------------------------
;        mm4:       If set then compute the mueller matrix.
;                   m_rcvrcorr,m_skycorr, and m_astro should not be set.
;                   You need a polarized source with enough patterns to do a fit
;                   in parallactic angle.
;    plt1yes:       if set then plot the PA dependencies, parameters, and
;                   mueller matrix elements.
;     ps1yes:       if set then generate post script files of the totalpower
;                   mueller matrix (same as screen output from plt1yes). An
;                   example output filename would be:
;                   lbw_1175_bd0_B0518+165_m4_10-AUG-2001.ps 
;                   If /byChnl is set then a 2nd plot of parameter vs freq
;                   will be written to:
;                   lbw_1175_bd0_B0518+165_m4frq_10-AUG-2001.ps 
;                   Both of these will be in the directory set by the
;                   keyword dirplot=
;      byChnl:      if set, compute the mueller matrix for the continuum 
;                   and then for each frequency channel.
;   ------------------------
;   SAVING DATA IN idl SAVE FILES
;   ------------------------
;    savemm0:       if set then save the 1d,2d fits (hb_arr,mmInfo_arr,
;                   beamin_arr,beamout_arr, and mm0procByChnl in an idl save
;                   file: mm0_ddmonyy.projid.n.sav  .
;                   If byChnl keyword was also set, then a second save
;                   file: mm0_ddmonyy.projid.n.sav.byChnl will hold 
;                   stkOffsets_chnl_arr. This is the stokes data by channel.
;                   The variable mm0procByChnl=1 if the channel data was
;                   also saved. These save files can be used later with the
;                   /onlymm4 keyword to just do the /mm4 processing.
;    savemm4:       if set and /mm4 was set then save the mueller matrix
;                   computations: (mmCmp_arr,mmCmpChn_arr,mmInfo_arr,
;                   mm4procByChnl) will be saved in the file:
;                   mm4_ddmonyy.projid.n.sav. mmInfo_arr is a copy of what
;                   would have been saved in /savemm0.
;   ------------------------
;   KEYWORDS FOR DEBUGGING .. normally not used
;   ------------------------
;    plt0yes:       if set then mm4 plots intermediate results (PA dependencies 
;                   before the fit on the screen); usually not set unless
;                   there are problems with the fit.
;       m7:         if set, then mm4  gets the continuum using the 'M7' method.
;                   It tries to excise interference from each spectrum using
;                   cumcorr (it is time consuming).
;    check:         checks the calc by plotting on the screen the
;                   mm-corrected input data; derived MM elements should be zero.
;                   Normally don't bother with this; useful for pgrm
;                   development and looking into problems with fits.

; negate_q:         multiplies uncorrected xmy by -1. always use 0 here.
;  keywait:         when doing the plots on the screen, wait for a keypress
;                   before continuing 
; ----------------------------------------------------------------------------
;
;DESCRIPTION:
;
;   mmproc is the general interface to carl heiles polarization calibration
;using the 'beetle' scans (rumor has it that beetles have 6 legs..). By
;default it will process all receivers, sources, and boards that it finds
;in the file. You can limit what is processed with the board, rcvnam, source,
;etc keywords described above.
;
;There are two basic modes for using this routine:
;
;1. You've taken some data on a source using the beetle scans and you want
;   to get the gain, Tsys, beamwidth, etc... You should run this routine as:
;
;   corfile='/share/olcor/corfile.17aug02.x102.1'
;   ntot=mmproc(corfile,scndata,mmInfo_arr,hb_arr,beamin_arr,beamout_arr,$
;               /m_rcvrcorr,/m_skycorr,/m_astro..   
;   with the optional parameters:  /phaseplot,/plot1d,/plot2,/savemm0)
;   All the info you want will be returned in mmInfo_arr.
;
;2. You've tracked a polarized source across a large fraction of its 
;   parallactic angle and you want to recompute the mueller matrix for this
;   receiver. Call mmproc with:
;
;   corfile='/share/olcor/corfile.18aug02.x102.1'
;   ntot=mmproc(corfile,scndata,mmInfo_arr,hb_arr,beamin_arr,beamout_arr,
;               mmCmp_arr,mmCmpChn_arr,/mm4... 
;   with optional keywords: /phaseplot,/plot1d,/plot2,/savemm0, 
;               /plt1yes,/ps1yes,/savemm4
;   The mueller matrix info will be in mmCmpm_arr.
;
;   In either case, use dirplot,dirsave to set the directory for the
;   output save files or ps files (if they were requested).
;
;After running the routine, you can replot the stripfits or 2d beam images
;with the routines: plot_beam1d, or plot_beam2d
;
;The startup of idl is:
;   idl
;   @mm0init
;   corfile='/share/olcor/...'
;   ntot=mmproc(corfile...)
;   You can then continue calling mmproc as many times as you want.
;
;SEE ALSO:
;   mmplot_beam1d,mmplot_beam2d,mm_structureDefs
;
;********************BEGIN WARNING NR 2*****************************
;
;   IF YOU RUN THIS WITHOUT MUELLER CORRECTING THE INPUT DATA,
;THEN THE BEAM MAPS FOR THE POLARIZED STOKES PARAMETERS WILL NOT BE FOR
;THE ***REAL*** STROKES PARAMETERS, BECAUSE WILL NOT HAVE BEEN CALIBRATED!
;*********************END WARNING NR 2*****************************
;-   
;history:
;1jan05: added tcalxx_430ch,tcalyy_430ch to mmproc_setup, cross_newcal
function mmprocherb,corfile,scndata,$
          mmInfo_arr,hb_arr,beamin_arr,beamout_arr,mmCmp_arr,mmCmpChn_arr,$
          tcalxx_board=tcalxx_board,tcalyy_board=tcalyy_board,polBad=polBad,$ 
          mmInfo_arrChn=mmInfo_arrChn,han=han,chnrng=chnrng,$
          sl=sl,retsl=retsl,dirsave=dirsave,dirplot=dirplot,$
          board=board,rcvnam=rcvnam,sourcename=sourcename,npatterns=npatterns,$
          m_rcvrcorr=m_rcvrcorr,m_skycorr=m_skycorr,m_astro=m_astro,$
          mm_pro_user=mm_pro_user,$
          plot1d=plot1d,print1d=print1d,plot2d=plot2d,print2d=print2d,$
          keywait=keywait,savemm0=savemm0,srcprint=srcprint,$
          phaseplot=phaseplot,mm4=mm4,onlymm4=onlymm4,$
          plt0yes=plt0yes,plt1yes=plt1yes,ps1yes=ps1yes,$
          check=check,negate_q=negate_q,bychnl=bychnl,savemm4=savemm4,m7=m7
        
    forward_function mm4


;
; 	don't bother to fit outside this
;
	if n_elements(chnrng) ne 2 then chnrng=[20,115]
	minchn=chnrng[0]
	maxchn=chnrng[1]
    lun=-1
	nchn=scndata.nchnls

;       DO THE SETUP REQUIRED FOR EACH RUN...

    numPat=mmproc_setup(corfile,scndata,lun,retsl,indForPat,$
                brdToUse,nfitTot,mmInfo_arr,hb_arr,beamin_Arr,beamout_arr,$
                stkOffsets_chnl_arr ,filesavenamemm0,filesavenamemm4,$
                tcalxx_board=tcalxx_board,tcalyy_board=tcalyy_board,$   
                sl=sl,board=board,rcvnam=rcvnam,onlymm4=onlymm4,$
                sourcename=sourcename,npatterns=npatterns,byChnl=byChnl,$
                dirsave=dirsave,dirplot=dirplot,$
                tcalxx_430ch=tcalxx_430ch,tcalyy_430ch=tcalyy_430ch)
    if numPat eq 0 then goto,nopatterns

    if (keyword_set(onlymm4)) then begin
        nfitTot=numPat
        goto,mm4start
    endif

;   GENERATE THE CALIBRATED DATA ORGANIZED INTO SCANS AND STRUCTURES...

    curFitInd=0
    for i=0,numPat - 1 do begin
        cross3_newcal,lun,retsl,indForPat[i], scndata,  $
            curFitInd,beamin_arr,hb_arr,mmInfo_arr,stkOffsets_chnl_arr,$
            numBrdsProcessed,$
            returnstatus, tcalxx, tcalyy,byChnl=byChnl,han=han,polBad=polBad,$
			tcalxx_430ch=tcalxx_430ch,tcalyy_430ch=tcalyy_430ch,$
            board=board,nocal=nocal, cumcorr= cumcorr, totalquiet= totalquiet,$
            phaseplot= phaseplot , mm_pro_user= mm_pro_user, $
            m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
        curFitInd=curFitInd+numBrdsProcessed
    endfor
    if lun ne -1 then begin
        free_lun,lun
        lun=-1
    endif
    if curFitInd eq 0 then goto,nopatterns
;
;   Shrink arrays if we didn't do all successfully
;
    if nfitTot ne curFitInd then begin
        nfitTot=curFitInd
        hb_arr=hb_arr[*,0:nfitTot-1]
        beamin_arr=beamin_arr[0:nfitTot-1]
        beamout_arr=beamout_arr[0:nfitTot-1]
		mmInfo_arr= mmInfo_arr[0:nfitTot-1]
        ;                                      [128,4iqu,60,4strip,nrc]
        if keyword_set(byChnl) then begin
            stkOffsets_chnl_arr=stkOffsets_chnl_arr[*,*,*,*,0:nfitTot-1]
        endif
    endif
;
;   updata beamout_arr
;
    beamout_azzapa,nfitTot,beamin_arr,beamout_arr
    beamout_arr.sourceflux=mmInfo_arr.srcflux
    beamout_arr.sourcename=mmInfo_arr.srcname


;----------------BEGIN THE BEAM PARAMETER PROCESSING LOOP------------------

    print,'doing beamfits.. processing ',nfitTot,' fits (patterns*freq)'

    FOR NRC= 0, nfitTot-1 DO BEGIN

;   DO THE 1-d BEAM FITTING FOR the continuum..

        beam1dfit, nrc, beamin_arr, beamout_arr

;;  DO THE 1-D BEAM FITTING FOR ALL CHNLS INDIVIDUALLY...
;;  this is normally done in mm4
        beam1dfit, nrc, beamin_arr, beamout_arr,stkOffsets_chnl_arr,/byChnl

;   PLOT THE BEAM1DFIT PARAMETERS...

        if ( keyword_set( plot1d)) then $
           plot_beam1d, nrc, mmInfo_arr, beamin_arr

;   PRINT THE 1-d BEAMFIT1D PARAMETERS...

        if ( keyword_set( print1d)) then $
            print_beam1d, nrc, beamout_arr

;   DO THE 2-D BEAMFIT total power
;
        beam2dfit, nrc, mmInfo_arr[nrc].cfr, beamin_arr, beamout_arr
;   CALCULATE BEAM AND SIDELOBE INTEGRALS. USE NTERMS=6...
        calc_beam2d, nrc, beamin_arr, beamout_arr

;   PRINT THE 2D BEAM PROPERTIES...
        if ( keyword_set( print2d)) then print_beam2d, beamout_arr[ nrc].b2dfit

;   PLOT THE 2D BEAM PROPERTIES...
        if ( keyword_set( plot2d)) then $
            plot_beam2d, beamout_arr[ nrc], 200, /show, nterms= 6

;
;	fill in rest of structure with 
        mmbmtostr, nrc, beamin_arr, beamout_arr,hb_arr[*,nrc], mmInfo_arr
;
; 	now loop over each channel for this nrc. just fake out the
;   routines moving the channel info to the continuum info
;
		beamOutW=beamout_arr[nrc]
		beamInW =beamin_arr[nrc]
		nrc0=0				; just use first entry
		print,'Start processing by channel. fitNum:',nrc
		if (nrc eq 0) then begin
			mmInfo_arrChn=replicate(mminfo_arr[nrc],nchn,nfitTot)
		endif
		mmInfoTmp=mmInfo_arr[nrc]
		print,'start 2d fit by chan'
		for ichn=minchn,maxchn do begin
			beamInW.stkoffsets_cont=reform(stkOffsets_chnl_arr[ichn,*,*,*,nrc])
			beamOutW.stripfit=beamout_arr[nrc].stripfit_chnl[ichn,*,*,*]
        	beam2dfit, nrc0, mmInfoTmp.cfr, beaminW, beamoutW
            calc_beam2d, nrc0, beaminW, beamoutW
        	mmbmtostr, 0, beaminW, beamoutW,hb_arr[*,nrc], mmInfoTmp
			mmInfo_arrChn[ichn,nrc]=mmInfoTmp
		endfor
		if minchn gt 0 then begin
			mmInfo_arrChn[0:minchn-1,nrc]=mmInfo_arrChn[minChn,nrc]
		endif
		if maxchn lt 127 then begin
			mmInfo_arrChn[maxChn-1:*,nrc]=mmInfo_arrChn[maxChn,nrc]
		endif

;   WAIT FOR A KEYSTROKE IF DESIRED...
        IF ( KEYWORD_SET( keywait)) THEN BEGIN
            print, 'hit a key to continue...'
            rwait = get_kbrd(1)
        ENDIF

    endfor

;-------save mm0 intermediate results to disk if desired------------

    if ( keyword_set( savemm0)) then begin
        mm0procByChnl= keyword_set(byChnl)
        save, hb_arr, mmInfo_arr, beamin_arr, beamout_arr,mm0procByChnl,$
                filename= filesavenamemm0
        print, 'INTERMEDIATE RESULTS SAVED IN ', filesavenamemm0
        if keyword_set(byChnl) then begin
            namebychnl=filesavenamemm0 + '.byChnl'
            save,stkOffsets_chnl_arr,file=namebychnl
        print, '                              ', namebychnl
        endif
    endif
;---------GENERATE THE SCREEN- AND ASCII FILE OF PRINTED SRC POLS, ETC---
;---------------------(IF DESIRED)---------------------------

    if ( keyword_set( srcprint)) then $
        mm9, filesavenamemm0, mmInfo_arr, beamout_arr

;---------------- do mm4 processing if desired -----------------
;   the following will probably fail if the same source is used on the
;   same rcvr more than once (different days) in the file
;
mm4start:
    IF ( KEYWORD_SET( MM4)) THEN BEGIN $
;
; loop over receivers, source, cfr.. allocate to hold number of fits/4
; since we require at least 4 patterns for a fit.
;
        mmCmpCnt=0
        mmCmp_arr   =replicate({muellerparams_carl},nFitTot/4) 
        if keyword_set(byChnl) then begin
            mmCmpChn_arr=replicate({muellerparams_carl},128,nFitTot/4) 
        endif else begin
            mmCmpChn_arr=''
        endelse
        rcvlist=mmInfo_arr[uniq(mmInfo_arr.rcvnum,$
                            sort(mmInfo_arr.rcvnum))].rcvnum
        srclist=mmInfo_arr[uniq(mmInfo_arr.srcname,$
                            sort(mmInfo_arr.srcname))].srcname
        cfrlist=mmInfo_arr[uniq(mmInfo_arr.cfr,sort(mmInfo_arr.cfr))].cfr
        for ircv=0,n_elements(rcvlist)-1 do begin 
            rcv=rcvlist[ircv]
            for isrc=0,n_elements(srclist)-1 do begin
                src=srclist[isrc]
                for icfr=0,n_elements(cfrlist)-1 do begin
                    cfr=cfrlist[icfr]
                    indx=where((mmInfo_arr.rcvnum eq rcv) and $ 
                               (mmInfo_arr.srcname eq src) and $    
                               (mmInfo_arr.cfr    eq cfr),count)
                    if count lt 4 then begin
                        print,string(7b),$
                'Too few patterns. skipping :',src,' rcv:',rcv,' cfr:',cfr
                    endif else begin
                    istat=mm4(dirplot, muellerparams_init, $
                        indx, hb_arr, mmInfo_arr, beamin_arr, beamout_arr, $
                        stkOffsets_chnl_arr,muellerparams1,muellerparams_chnls,$
                        plt0yes=plt0yes, plt1yes=plt1yes, ps1yes=ps1yes, $
                        check=check, negate_q=negate_q, byChnl=byChnl,m7=m7)
                            if istat eq 1 then begin
                                mmCmp_arr[mmCmpCnt]=muellerparams1
                                if keyword_set(byChnl) then begin
                                    mmCmpChn_arr[*,mmCmpCnt]=$
                                            muellerparams_chnls
                                endif
                                mmCmpCnt=mmCmpCnt+1 
                            endif
                    endelse
                endfor ; cfr loop
            endfor ; srcloop
        endfor ; rcvloop
        if mmCmpCnt eq 0 then goto,nommcomputed
        if mmCmpCnt lt n_elements(mmCmp_arr) then begin
            mmCmp_arr= mmCmp_arr[0:mmCmpCnt-1]
            if keyword_set(byChnl) then begin
                mmCmpChn_arr= mmCmpChn_arr[*,0:mmCmpCnt-1]
            endif
        endif

        if keyword_set(savemm4) then begin  
            mm4procByChnl= keyword_set(byChnl)
            print,'Saving mm4 data to',filesavenamemm4
            save,mmCmp_arr,mmCmpChn_arr,mmInfo_arr,mm4procByChnl,file=filesavenamemm4
        endif
            
    endif


return,nfitTot
nopatterns:
    print,'No patterns found'
    return,0
nommcomputed:
    mmCmp_arr=''
    mmCmp_Chn_arr=''
    print,'No mueller matrices computed.. not enought patterns'
    return,0
end
