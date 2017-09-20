pro mmproc, outpath, gbtdatafile, $
	calbefore, strip, calafter, $
	board, tcalxx_board, tcalyy_board, $
	scndata, $
	hb_arr, a, fp, beamin_arr, beamout_arr, indx, $
	beamin_cont_arr, beamout_cont_arr, $
;
;KEYWORDS RELEVANT TO MM0 (which reads data, calculates beams):

;FIRST, KEYWORDS WITHIN MM0 THAT DO MM CORRECTION TO THE INPUT DATA...
        mm_corr= mm_corr, mm_pro_user= mm_pro_user, $
        m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro,$

;SECOND, KEYWORDS WITHIN MM0 RELEVANT TO PLOTTING...
	plot1d= plot1d, print1d= print1d, plot2d= plot2d, $
	print2d= print2d, keywait= keywait, npatterns= npatterns, $
	savemm0=savemm0, srcprint= srcprint, phaseplot= phaseplot, $
	nterms=nterms, $
;
;KEYWORDS RELEVANT TO MM4 (which solves for mueller matrices):
	mm4_1d=mm4_1d, mm4_2d=mm4_2d, nominal_linear=nominal_linear, $
;THE FOLLOWING TWO MUST BE SET...THEY SPECIFY WHAT SRC, FRQ YOU PROCESS..
	sourcename=sourcename, rcvr_name=rcvr_name, $
;THE FOLLOWING ARE OPTIONAL, HAVING TO DO WITH DATA DISPLAY MAINLY...
        plt0yes=plt0yes, plt1yes=plt1yes, ps1yes=ps1yes, $
        check=check, negate_q=negate_q, chnl=chnl, saveit=saveit, $
        m7=m7, $
;FINALLY, WE ADD THE KEYWORD SQUOOSH; SET IT TO INCLUDE SQUOOSH IN THE FIT.
	squoosh= squoosh, totalquiet=totalquiet
;+
;PURPOSE: general processing routine for 'beetle' scans.
;
;********************BEGIN WARNING NR 1*****************************
;
;	ASSUMPTION: ASSUMPTION IS THAT CFR IS THE SAME FOR ALL
;RECORDS. Specifically, this assumes that there is a one to one
;correpsondence between board number and cfr, which is not necessarily
;true for LBW...
;
;	FOR THE M4 PART, THE ASSUMPTION IS THAT ALL RECORDS REFER
;TO THE SAME SOURCE.
;
;*********************END WARNING NR 1*****************************
;
;********************BEGIN WARNING NR 2*****************************
;
;	IF YOU RUN THIS WITHOUT MUELLER CORRECTING THE INPUT DATA,
;THEN THE BEAM MAPS FOR THE POLARIZED STOKES PARAMETERS WILL NOT BE FOR
;THE ***REAL*** STROKES PARAMETERS, BECAUSE WILL NOT HAVE BEEN CALIBRATED!
;
;*********************END WARNING NR 2*****************************
;
;INPUTS:
;
;	OUTPATH, path for the intermediate and final output files.
;

;	GBTDATAFILE: name of gbtdatafile
;
;	BOARD: process this board
;
;	TCALXX_BOARD, TCALYY_BOARD: possibility of user-specified cal
;values, an array of 4 ( four boards). if the cal value is negative, use
;the value read from phil;s files; this is the default. positive means
;pgrm will use that specified value. See the more complete discussion in
;the documentation for CROSS3_NEWCAL.
;
;	SCNDATA: structure defined at beginning of run
;
;OUTPUTS:
;
;	HB_ARR,  the structure array of B.H structures from the 
;gbtdatafile data.
;
;	A, a structure array with useful quantities.
;
;	FP, a structure array with some beamfit paramters.
;
;	beamin_arr, a strucure array of quans relating to the
;beamfits--maintly input quantities.
;
;	beamout_arr, a strucure array of quans output of beamfits.
;
;KEYWORDS:
;
;KEYWORDS RELEVANT TO THE MM0 PORTION (THE GENERTION OF BEAM MAPS)
;
;FIRST, KEYWORDS RELEVANT TO MM CORRECTION OF INPUT DATA. THE DATA,
;WHETHER CORRECTED OR NOT, RESIDES IN BEAMIN_ARR.STOKESC1

;	MM_CORR: Mueller-correct the noise-diode calibrated data
;
;	MM_PRO_USER: User-supplied Mueller procedure name to supplant the 
;default (e.g. mmp_lbw_08sep00_nocalcorr.pro; defined in getrcvr.pro . 
;set equal to '' zero to use the default; otherwise, it's a 4X4.
;
;        M_RCVRCORR= if set, correct for rcvr. set this if you want to
;get mm-corrected data. don't set it if you want to solve for mm parameters.
;If you want to check to see how well a mm matrix is applied, set this
;and don't set m_skycorr and m_astro; then solve for the mm parametrs.
;they should be zero.
;
;	M_SKYCORR= if set, corrects for sky rotation. set this if you want to
;get mm-corrected data. don't set it if you want to solve for mm parameters.
;
;	M_ASTRO:if set, corrects electronics to astron PA definition and
;also Stokes V definition. 
;
;	plot1d: plot 1d fits on the screen
;
;	print1d: print 1d fits on the screen
;
;	plot2d: plot 2d fits on the screen
;
;	print2d: print 2d fits on the screen
;
;	SAVEMM0: save the intermediate mm0 output to disk
;
;	PHASEPLOT, make the phase vs frq plots for cal and source.
;
;	MM4_1D: do MM4 processing (derives Mueller matrix elements from  1d stripscans)
;	MM4_2D: do mm4_2d processing (derives Mueller matrix elements from  2d beammaps)
;
;
;       NOMINAL_LINEAR: if set, forces abs(alpha) lt 45deg and adjusts
;       psi.
;
;KEYWORDS RELEVANT TO THE MM2 PORTION (THE GENERTION OF MUELLER MATRIX
;ELEMENTS)

;       PLT0YES: plots intermediate results (PA dependencies on the
;screen); usually not set unless there are problems with the fit.
;
;       PLT1YES: plots final results on the screen--the PA dependencies
;plus the Mueller paramters and matrix elements.
;
;       PS1YES: generates ps file with final results.
;
;       CHECK: checks the calc by plotting on the screen the
;mm-corrected input data; derived MM elements should be zero. Normally
;don't bother with this; useful for pgrm development and looking into 
;problems wiht fits.
;
;       NEGATE_Q=NEGATE_Q: multiplies uncorrected xmy by -1. always use
;0.
;
;       SAVEIT: save final numerical results to disk if set
;
;       CHNL: if set, it does all the channels as well as the
;continuum. this is done at the end. channels come
;from beamout_arr.stripfit_chnl[nchnl, *,*,*]. output is ps plots.
;
;       M7: if set, it gets the continuum using the 'M7' method. This
;means that it tries to excise interference from each spectrum. time
;consuming.

;-	 

;NR OF PATTERNS...
nrcmax= n_elements( strip)/4

;print, scndata.ptsperstrip

;DO THE SETUP REQUIRED FOR EACH RUN...
setup_eachtime, strip, $
	outpath, gbtdatafile, board, sourcename, nrcmax, $
        beamin, beamin_arr, $
        beamout, beamout_arr, $
        beamin_initial_cont, beamin_cont_arr, $
        beamout_initial_cont, beamout_cont_arr, $   
        filesavename1, filesavename2, $
        scndata, npatterns_max, successful, noplotcounter, $
        noplott, noprintt, keywaitt

monitor=0

;print, scndata.ptsperstrip
;stop

;GENERATE THE CALIBRATED DATA ORGANIZED INTO SCANS AND STRUCTURES...
cor_gbtcal, board, scndata, $
	calbefore, strip, calafter, $
        noplott, nrc, $
        tcalxx_board, tcalyy_board, $
        a, fp, b_0, hb_arr, $
        beamin, beamin_arr, $
        beamout, beamout_arr, $
	mm_corr= mm_corr, mm_pro_user= mm_pro_user, $
        m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro, $
	phaseplot= phaseplot, totalquiet=totalquiet

;stop

;----------------BEGIN THE BEAM PARAMETER PROCESSING LOOP------------------

FOR NRC= 0, NRCMAX-1 DO BEGIN
;FOR NRC= 0, 0 DO BEGIN

;DO THE 1-d BEAM FITTING FOR CONTINUUM...
beam1dfit, nrc, beamin_arr, beamout_arr

;;DON'T DO THIS UNTIL IT IS NEEDED!!!!
;;DO THE 1-D BEAM FITTING FOR ALL CHNLS INDIVIDUALLY...
;beam1dfit, nrc, beamin_arr, beamout_arr, /chnls

;PLOT THE BEAM1DFIT PARAMETERS...
if ( keyword_set( plot1d)) then $
        plot_beam1d, nrc, board, beamin_arr, beamout_arr

;stop, 'after plot_beam1d''

;PRINT THE 1-d BEAMFIT1D PARAMETERS...
if ( keyword_set( print1d)) then $
        print_beam1d, nrc, beamout_arr

;DO THE 2-D BEAMFIT
beam2dfit, nrc, a[ 0].cfr, beamin_arr, beamout_arr, squoosh=squoosh

;CALCULATE BEAM AND SIDELOBE INTEGRALS. USE NTERMS=6...
calc_beam2d, nrc, beamin_arr, beamout_arr

;stop, 'after beam2dfit'

;PRINT THE 2D BEAM PROPERTIES...
if ( keyword_set( print2d)) then print_beam2d, beamout_arr[ nrc].b2dfit

;PLOT THE 2D BEAM PROPERTIES...
if ( keyword_set( plot2d)) then $
        plot_beam2d, beamout_arr[ nrc], 200, /show, nterms=nterms

mmtostr_carl, nrc, nrcmax, board, beamin_arr, beamout_arr, a, fp

;WAIT FOR A KEYSTROKE IF DESIRED...
IF ( KEYWORD_SET( KEYWAIT)) THEN BEGIN
print, 'hit a key to continue...'
rwait = get_kbrd(1)
ENDIF

ENDFOR

;pltfilename, indx, a, 'mm0', '.sav', mm0title, mm0filename 
;filename=outpath+ mm0filename

;-------save mm0 intermediate results to disk if desired------------

;stop, 'stop mmproc before create...'

create_beaminout_cont, beamin_arr, beamout_arr, $
	beamin_cont_arr, beamout_cont_arr

IF ( KEYWORD_SET( SAVEMM0)) THEN BEGIN
save, a, fp, beamin_cont_arr, beamout_cont_arr, $
        filename= filesavename1, /VERB, /COMP
print, 'INTERMEDIATE RESULTS SAVED IN ', filesavename1
ENDIF

;stop

;---------GENERATE THE SCREEN- AND ASCII FILE OF PRINTED SRC POLS, ETC---
;---------------------(IF DESIRED)---------------------------

if ( keyword_set( srcprint)) then $
	mm9, filesavename1, a, beamout_arr

;---------------- do mm4 processing if desired -----------------

;stop, 'mmproc before mm4...'

;---DO MM4 PROCESSING IF DESIRED------------------------
IF ( KEYWORD_SET( mm4_1d)) THEN BEGIN $

indx = where( (a.srcname eq sourcename) and (a.rcvnam eq rcvr_name), count)

IF (count eq 0) THEN BEGIN
        print, string(7b)
        message, 'NO SOURCES FOUND!!! SKIPPING MM4.', /INFO
	return
ENDIF

mm4, outpath, filesavename1, muellerparams_init, $
;mm4, outpath, mm0filename, muellerparams_init, $
        indx, hb_arr, a, beamin_arr, beamout_arr, $
        muellerparams1, $
        plt0yes=plt0yes, plt1yes=plt1yes, ps1yes=ps1yes, $
        check=check, negate_q=negate_q, chnl=chnl, saveit=saveit, $
        m7=m7, nominal_linear=nominal_linear
ENDIF

;---DO MM4_2D PROCESSING IF DESIRED------------------------
IF ( KEYWORD_SET( mm4_2d)) THEN BEGIN $

indx = where( (a.srcname eq sourcename) and (a.rcvnam eq rcvr_name), count)

IF (count eq 0) THEN BEGIN
        print, string(7b)
        message, 'NO SOURCES FOUND!!! SKIPPING MM4_2D.', /INFO
        return
ENDIF

mm4_2d, outpath, filesavename1, muellerparams_init, $
        indx, hb_arr, a, beamin_arr, beamout_arr, $
        muellerparams1, $
        plt0yes=plt0yes, plt1yes=plt1yes, ps1yes=ps1yes, $
        check=check, negate_q=negate_q, chnl=chnl, saveit=saveit, $
        m7=m7, nominal_linear=nominal_linear
;STOP

ENDIF

end; mmproc
