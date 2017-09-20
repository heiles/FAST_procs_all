;+
;NAME:
;coronl  - open the online datafile
;SYNTAX: - lun=coronl(calfile=calfile)
;ARGS:  calfile     if set then use the calibrate file rather than corfile
;DESCRIPTION:
;   open the online datafile /share/olcor/corfile. Return
;the lun to access the file. This should only be used by the
;people that are actively taking data on the telescope.
;-
function    coronl ,calfile=calfile
    file=(keyword_set(calfile))?'/share/olcor/calfile':'/share/olcor/corfile'
    openr,lun,file,/get_lun
    return,lun
end
