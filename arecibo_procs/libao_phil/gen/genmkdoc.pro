;
; extract documentation , create html file
;
inpd=aodefdir() + 'gen'
outd=aodefdir(/doc) + 'gendoc.html'
mk_html_help_ph,inpd,outd,title='general purpose idl routines',bgcolor='white'
explainbuild,'gen',inpd,aodefdir()+'doc/'
end
