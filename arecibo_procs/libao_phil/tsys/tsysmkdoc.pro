;
; extract documentation , create html file
;
dirIn=aodefdir() + 'tsys'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'tsysdoc.html',$
         title='daily tsys idl routines',bgcolor='white'

explainbuild,'tsys',dirIn,aodefdir()+'doc/' 
end
