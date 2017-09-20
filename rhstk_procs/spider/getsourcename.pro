function getsourcename, gbtdatafile

;+
;purpose: get the source name given the input file name. assumes file
;name looks like...
;
;3C27.Rcvr1_2.0.03Jan07.05:19:36.sav
;  ^
;  |
;  |
;  |
;  this is the sourcename
;
;do it by finding the location of the second dot; get the next character.
;
; oct 8, 2006: updated for spectrometer file names...
;
; nov 28, 2006: tim changed the spectral processor file names to match
; those of the spectrometer.  now, the filename looks like this:
;
; sourcename_backend_receiver_bandwidth(MHz)_board#_date_timestamp.sav
;
; examples:
; 3C286_sp_Rcvr4_6_5_1_03Jan11_10:30:07.sav
; W3_acs_Rcvr4_6_12.5_0_06Aug07_09:48:57.sav 
;
; HOWEVER, the source name *might* have an underscore, so we need to
; count separators from the rear, e.g.:
; sun_spillover_sp_Rcvr1_2_5_2_03Sep19_16:25:10.sav
;
;-

; UNDERSCORE IS THE STRING SEPARATOR...
sep = '_'

; CHECK FOR NON-STANDARD NAME...
datafile_components = strsplit(gbtdatafile,sep,/EXTRACT,COUNT=ncomponents)

; GET THE CORRECT COMPONENT...
sourcename = strjoin(datafile_components[0:(0 + ncomponents - 8)],sep)

return, sourcename
end
