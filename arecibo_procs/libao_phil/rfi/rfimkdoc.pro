;
; extract documentation , create html file
;
dirIn=aodefdir() + 'rfi'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'rfidoc.html',$
         title='rfi idl routines',bgcolor='white'

explainbuild,'rfi',dirIn,aodefdir()+'doc/' 
end
