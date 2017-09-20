;
; extract documentation , create html file
;
dirIn=aodefdir() + 'was2'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'wasdoc.html',$
         title='was (wapp spectral line) idl routines',bgcolor='white'
explainbuild,'was',dirIn,aodefdir()+'doc/'
end
