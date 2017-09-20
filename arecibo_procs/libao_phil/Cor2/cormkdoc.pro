;
; extract documentation , create html file
;
dirIn=aodefdir() + 'Cor2'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'cordoc.html',$
         title='correlator idl routines',bgcolor='white'

explainbuild,'cor',dirIn,aodefdir()+'doc/' 
end
