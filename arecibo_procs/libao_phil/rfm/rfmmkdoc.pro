;
; extract documentation , create html file
;
dirIn=aodefdir() + 'rfm'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'rfmdoc.html',$
         title='RF radiation monitor idl routines',bgcolor='white'

explainbuild,'rfm',dirIn,aodefdir()+'doc/' 
end
