;
; extract documentation , create html file
;
dirIn=aodefdir() + 'wind'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'winddoc.html',$
         title='wind meter idl routines',bgcolor='white'

explainbuild,'wind',dirIn,aodefdir()+'doc/' 
end
