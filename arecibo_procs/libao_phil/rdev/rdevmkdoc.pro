;
; extract documentation , create html file
;
inpd=aodefdir() + 'rdev'
outd=aodefdir(/doc) + 'rdevdoc.html'
mk_html_help_ph,inpd,outd,title='rdev idl routines',bgcolor='white'
explainbuild,'rdev',inpd,aodefdir()+'doc/'
end
