;THE FOLLOWING COMBINATION OF KEYWORDS MAKES THE FOLLOWING HAPPEN:
;
;	BEAMS ARE SOLVED FOR AND SAVED
;	MUELLER MATRIX CORRECTION IS NOT APPLIED TO THE DATA.
;	MUELLER PARAMETERS ARE DERIVED

;common subsidiary choices include:
;
;	ps plot of the PA dependence and coefficients (PS1YES, below)
;	don't save the results to disk (SAVEIT, below)	
;	don't do the strip solutions (MM4_1D, below)

;KEYWORDS FOR MM0...
plot1d= 1	;makes plots of the strips in all 4 stokes parameters. 
print1d= 0	;prints solutions of the strips.
plot2d= 1	;displays the 2d beam in greyscale.
print2d= 1	;prints the ls-fit 2d beam parameters
keywait= 0	;waits after each pattern for you to strike a key
npatterns= 1	;i don't know what this does. setting it to 1 works.
savemm0=0	;saves calbeam results. i think this has no effect--always 
		;saved. but if it does have an effect, we don't want to
		;save beam results for mm-uncalibrated data, so set to 0.
phaseplot=1	;do the phase vs freq plot for each dataset.

;DO THE FOLLOWING TO ***NOT*** MM-CORRECT THE DATA...
mm_corr=0	;apply Mueller matrix correction, including the following distinct
		;contributions as defined in AOTM 2000-04:
m_rcvrcorr= 0	;apply M_tot correction as defined in AOTM 2000-04
m_skycorr= 0	;apply M_sky correction as defined in AOTM 2000-04
m_astro= 0	;apply M_astron as defined in  AOTM 2000-04.

;PRINT SOURCE POL PARAMETERS?
srcprint= 0	;print the polarization, etc, of the source, as derived from the
		;source deflection. the source pol is correct only if all of the
		;Mueller matrix corrections have been applied, i.e. if all of the
		;above correction paramters are set.

;IMPORTANT KEYWORD: SELECT THE MUELLER MATRIX IF YOU WANT TO OVERRIDE THE DEFAULT...
mm_pro_user= ''	;making this blank or undefined uses default...

;SET THE FOLLOWING AS SHOWN TO PREVENT A MUELLER MATRIX (POLCAL) CALIBRATION...
mm4_1d=1	;do polcal solution using each STRIP. not great because
		;strips might not go thru centre of source. useful for
		;sources whose pa changes rapidly; strips are shorter than patterns.

mm4_2d=1	;do polcal solution using each PATTERN. somewhat
		;inaccurate if pa changes rapidly thru a pattern.

plt0yes= 0	;plot intermediate results (versus PA) on the terminal screen. 
		;usually not set unless there are problems.
plt1yes= 1	;plt final results on the screen, the nice plot with PA dependencies
		;and a listing of the derived parameters and the Mueller matrix.

chnl= 0		;set to do all the inidividual channels in addition the usual fit, 
		;which is to the avg over channels. This is done at the end and 
		;takes a long time. The output is ps plots.

saveit=1	;save final numerical results to disk.

m7=0		;use the 'M7' method, which attempts to excise interference. 
		;time consuming, and i don't think it works properly as of aug03.

;GET PS OUTPUT OF THE FINAL RESULT IF YOU WISH...
ps1yes= 1	;set to get ps results in addition to the terminal screen. ps filename
		;is generated automatically.

;if you are really into it...
check= 0	;set to apply the matrix after deriving it and then rederiving it. 
		;the rederived matrix should be unitary. a better way to do this is to 
		;derive the matrix, put it into the rcvr file, and then rerun
		;the software by both APPLYING THE MATRIX and then DERIVING IT.

