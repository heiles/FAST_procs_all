;
; extract documentation , create html file
;
inpd=aodefdir() + 'wst'
outd=aodefdir(/doc) + 'wstdoc.html'
mk_html_help_ph,inpd,outd,title='wst idl routines',bgcolor='white'
explainbuild,'wst',inpd,aodefdir()+'doc/'
end
