;
; extract documentation , create html file
;
inpd=aodefdir() + 'pdev'
outd=aodefdir(/doc) + 'pdevdoc.html'
mk_html_help_ph,inpd,outd,title='pdev idl routines',bgcolor='white'
explainbuild,'pdev',inpd,aodefdir()+'doc/'
end
