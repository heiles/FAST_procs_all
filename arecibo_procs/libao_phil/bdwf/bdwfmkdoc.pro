;
; extract documentation , create html file
;
dirIn=aodefdir() + 'bdwf'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'bdwfdoc.html',$
         title='mock brown dwarf idl routines',bgcolor='white'

explainbuild,'bdwf',dirIn,aodefdir()+'doc/' 
end
