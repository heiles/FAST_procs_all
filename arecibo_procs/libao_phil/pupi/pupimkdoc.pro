;
; extract documentation , create html file
;
dirIn=aodefdir() + 'pupi'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'pupidoc.html',$
         title='Puppi idl routines',bgcolor='white'

explainbuild,'pupi',dirIn,aodefdir()+'doc/' 
end
