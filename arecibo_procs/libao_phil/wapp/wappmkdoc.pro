;
; extract documentation , create html file
;
inpd=aodefdir() + 'wapp'
mk_html_help_ph,inpd,$
        aodefdir(/doc) + 'wappdoc.html',$
         title='wapp idl routines',bgcolor='white'
explainbuild,'wapp',inpd,aodefdir()+ 'doc/'
end
