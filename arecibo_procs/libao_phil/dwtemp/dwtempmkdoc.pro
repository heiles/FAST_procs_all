;
; extract documentation , create html file
;
inpd=aodefdir()+ 'dwtemp'
outd=aodefdir(/doc) + 'dwtempdoc.html'
mk_html_help_ph,inpd,outd,title='idl routines to look at dewar temps',$
	bgcolor='white'
end
