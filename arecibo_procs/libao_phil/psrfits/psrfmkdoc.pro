;
; extract documentation , create html file
;
inpd=aodefdir() + 'psrfits'
outd=aodefdir(/doc) + 'psrfdoc.html'
mk_html_help_ph,inpd,outd,title='psrfits idl routines',bgcolor='white'
explainbuild,'psrf',inpd,aodefdir()+'doc/'
end
