pro mm2_read, pathin, inputfilename, sourcename, rcvr_name, $
	hb_arr, a, beamin_arr, beamout_arr, $
	indx

;+
; PURPOSE: Read the file and select the indx numbers of the source.
;Called by @mueller2_cal.idl. The info generated herein is used by
;Mueller4, 5, and getbeams.
;
; INPUTS:
;	PATHIN, input path for filename
;
;	FILENAME, name of input file
;
;	SOURCENAME, name of source to process
;
;	RCVR_NAME, name of rcvr to process
;
;;OUTPUTS:
;
;	A, structure with hdr data, the original b
;
;	BEAMOUT, the output fit quantities
;
;	INDX, the index of a and beamout structures that apply to the
;given sourcename and rcvr_name
;-	


;RESTORE (READ) THE SAVED DATA 
restore, pathIN + inputfilename ;;;;, /ver

;GET THE INDX NUMBERS OF THE SELECTED SOURCE/RECEIVER COMBINATION. 
getrcvr, 0, rcvr_name, rcvrn

indx = where( (a.srcname eq sourcename) and (a.rcvnum eq rcvrn), count)

IF (count eq 0) THEN BEGIN 
        print, ' ' 
        print, 'NO SOURCES FOUND!!! ', string(7b) 
;       STOP 
ENDIF

;count_indx= count

return

end
