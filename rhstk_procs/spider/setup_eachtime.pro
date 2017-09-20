pro setup_eachtime, strip, $
	path, filename, board, sourcename, npatterns, $
	beamin, beamin_arr, $
	beamout, beamout_arr, $
	beamin_initial_cont, beamin_cont_arr, $
	beamout_initial_cont, beamout_cont_arr, $
	filesavename1, filesavename2, $
	scndata, npatterns_max, successful, noplotcounter, $
	noplott, noprintt, keywaitt

;+
;PURPOSE:
;	initializes variables that need initializing every time a new
;bunch of processing, e.g. a new board, is begun.
;-

;DEFINE THE DEFAULT NUMBER OF PATTERNS DONE (TO DEFINE ARRAY SIZES FOR OUTPUT)

makebeaminout, scndata, strip, beamin, beamin_initial_cont, $
         beamout, beamout_initial_cont

;beamin= {beaminput}
;beamout= {mmoutput}
;beamin_initial_cont= {beaminput_cont}
;beamout_initial_cont= {mmoutput_cont}

;CREATE ARRAYs OF BEAMIN, beamout...
beamin_arr= replicate( beamin, npatterns)
beamout_arr= replicate( beamout, npatterns)

beamin_cont_arr= replicate( beamin_initial_cont, npatterns)
beamout_cont_arr= replicate( beamout_initial_cont, npatterns)

;DEFINE THE ESTIMATE FOR DPHASE/DFREQ IN UNITS OF RADIANS PER MHZ...
;A NONFLIPPED RECEIVER WILL HAVE ROUGHLY THIS PHASE SLOPE...
;scndata.dpdf = +0.10
;scndata.dpdf = +50.0
; TR Jun 26 2007 ^^^ To make life easier, we set the default value of
; scndata.dpdf to +0.10 in 
; beamcal/stg2/procs/setup_initialize_gbtcal.idl.pro
; if it's set to zero for some reason, then let's avoid this by changing to
; +0.10 here:
if (scndata.dpdf eq 0.0) then scndata.dpdf = +0.10

;-----------------FILENAMES-------------------------

; JUN 19, 2007 TIM CHANGES BECAUSE THIS NAMING SCHEME IS NOW BROKEN...
;filesavename1 = path + 'mm0_' + 'bd' +   string(board, format='(i1)') + $
;	'_' + sourcename + strmid( filename, strpos( filename, '.')) + '.sav'

filesavename1 = path + 'mm0_' + filename + '.sav'

; THIS FILENAME IS NEVER USED...
filesavename2 = path + 'strpstk_' + 'mm0_' + 'bd' +  $
         string(board, format='(i1)') + '_' + sourcename + $
         strmid( filename, strpos( filename, '.')) + '.sav'

;----------------OTHER-------------------------------

;ELIMINATE ERROR MESSAGES
;!quiet=1

;INITIALIZE CERTAIN UTILITY VARIABLES...
successful=1
noplotcounter = 0l

;CHECK FOR DEFINITION OF NOPLOT, ETC...OTHERWISE SET DEFAULTS.
if (n_elements( noplott) eq 0) then noplott=1
if (n_elements( noprintt) eq 0) then noprintt=1
if (n_elements( keywaitt) eq 0) then keywaitt=0

return
end


