;+
;NAME:
;mkallidldoc - create all html documentation.
;SYNTAX: @mkallidldoc
;
;DESCRIPTION:
;   Create all of the html documentation in the directory specified by
;aodefdir(/doc). The routine will create a temporary file /tmp/mkallidldoc.pro
;and then executes it. It deletes it when done.
; You need write access to the aodefdir(/doc) directory and to /tmp
;-
;


docList=file_search(aodefdir(),"*mkdoc.pro")
tmpfile='/tmp/mkallidldoc.pro'
openw,lun,tmpfile,/get_lun
for i=0,n_elements(docList)-1 do printf,lun,'.run ' + docList[i]
free_lun,lun
@/tmp/mkallidldoc
$rm /tmp/mkallidldoc.pro

