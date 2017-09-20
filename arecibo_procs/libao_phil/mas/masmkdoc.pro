;
; extract documentation , create html file
;
inpd=aodefdir() + 'mas'
outd=aodefdir(/doc) + 'masdoc.html'
mk_html_help_ph,inpd,outd,title='mas idl routines',bgcolor='white'
explainbuild,'mas',inpd,aodefdir()+'doc/'
end
