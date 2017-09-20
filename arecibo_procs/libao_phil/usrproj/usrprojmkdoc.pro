;
; extract documentation , create html file
;
inpd=aodefdir() + 'usrproj'
outd=aodefdir(/doc) + 'usrprojdoc.html'
mk_html_help_ph,inpd,outd,title='idl routines for user projects',bgcolor='white'
explainbuild,'usrproj',inpd,aodefdir()+'doc/'
end
