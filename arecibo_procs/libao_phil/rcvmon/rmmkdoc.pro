;
; extract documentation , create html file
;
dirIn=aodefdir() + 'rcvmon'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) +  'rcvmondoc.html',$
         title='Rcvr monitoring routines',bgcolor='white'
explainbuild,'rcvmon',dirIn,aodefdir()+'doc/'
end
