;+
;NAME:
;pscol - send plot output to color postscipt file.
;SYNTAX pscol,filename,_extra=e,fullpage=fullpage
;ARGS:
;   filename: string filename for outputfile. default is idl.ps
;KEYWORDS:
;   fullpage: if set then set the pagesize 5 by 10 inches.
;             the default is 5 by 7.
;  _extra   : e  pass to device  command.
;DESCRIPTION:
;   Set plot output destination to a color postscript file.
;When done plotting use:
; hardcopy
; x
;to return to terminal output.
;SEE ALSO:
; pagesize, ps, hardcopy, x
;-

pro pscol, filename, _extra=e,fullpage=fullpage
;
; setup for ps color .. reload phils color table with col options
set_plot, 'ps'
if (n_params() gt 0) then begin
  device, file=filename
endif
device,/color
if not keyword_set(fullpage) then fullpage=0
pagesize,fullpage=fullpage
if(n_elements(e) gt 0) then begin
  device, _extra=e
endif
ldcolph,/pscol
return
end
