;
; extract documentation , create html file
;
dirIn=aodefdir() + 'tec'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'tecdoc.html',$
         title='atm tec idl routines',bgcolor='white'

explainbuild,'tec',dirIn,aodefdir()+'doc/' 
end
