;
; extract documentation , create html file
;
dirIn=aodefdir() + 'spwr'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'spwrdoc.html',$
         title='site power idl routines',bgcolor='white'

explainbuild,'spwr',dirIn,aodefdir()+'doc/' 
end
