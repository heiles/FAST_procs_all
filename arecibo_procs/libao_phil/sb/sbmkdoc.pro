;
; extract documentation , create html file
;
dirIn=aodefdir() + 'sb'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'sbdoc.html',$
         title='sband transmitter idl routines',bgcolor='white'

explainbuild,'sb',dirIn,aodefdir()+'doc/' 
end
