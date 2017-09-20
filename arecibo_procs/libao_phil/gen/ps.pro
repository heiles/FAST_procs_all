;+
;NAME:
;ps - send plot output to postscipt file.
;SYNTAX ps,filename,_extra=e,fullpage=fullpage
;ARGS:
;   filename: string filename for outputfile. default is idl.ps
;KEYWORDS:
;   fullpage: if set then set the pagesize 5 by 10 inches.
;             the default is 5 by 7.
;  _extra   : e  pass to device  command.
;DESCRIPTION:
;   Set plot output destination to a postscript file. 
;When done plotting use:
; hardcopy
; x 
;to return to terminal output.
;SEE ALSO:
; pagesize, pscol, hardcopy, x
;-
pro ps, filename, _extra=e,fullpage=fullpage
set_plot, 'ps'
if (n_params() gt 0) then begin
  device, file=filename
endif
if not keyword_set(fullpage) then fullpage=0
pagesize,fullpage=fullpage

if(n_elements(e) gt 0) then begin
  device, _extra=e
endif
return
end
