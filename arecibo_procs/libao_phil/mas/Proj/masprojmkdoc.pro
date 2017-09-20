;
; extract documentation , create html file
;
inpd=aodefdir() + 'mas/Proj'
outd=aodefdir(/doc) + 'masprojdoc.html'
mk_html_help_ph,inpd,outd,title='masProjects idl routines',bgcolor='white'
explainbuild,'masproj',inpd,aodefdir()+'doc/'
end
