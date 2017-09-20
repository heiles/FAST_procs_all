;
; extract documentation , create html file
;
inpd=aodefdir() + 'rfirms'
outd=aodefdir(/doc) + 'rfirmsdoc.html'
mk_html_help_ph,inpd,outd,title='routines to access rfi rms data',$
	bgcolor='white'
explainbuild,'rfirms',inpd,aodefdir()+'doc/'
end

