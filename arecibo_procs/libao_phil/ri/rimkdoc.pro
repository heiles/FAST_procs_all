;
; extract documentation , create html file
;
inpd=aodefdir() + 'ri'
outd=aodefdir(/doc) + 'ridoc.html'
mk_html_help_ph,inpd,outd,title='ri (a/d) idl routines',bgcolor='white'
explainbuild,'ri',inpd,aodefdir()+'doc/'
end
