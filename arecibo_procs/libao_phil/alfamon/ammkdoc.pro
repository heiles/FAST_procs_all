;
; extract documentation , create html file
;
dirIn=aodefdir() + 'alfamon'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) +  'alfamondoc.html',$
         title='Alfa Rcvr monitoring routines',bgcolor='white'
explainbuild,'alfamon',dirIn,aodefdir()+'doc/'
end
