;
; extract documentation , create html file
;
dirIn=aodefdir() + 'atm'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'atmdoc.html',$
         title='aeronomy idl routines',bgcolor='white'
explainbuild,'atm',dirIn,aodefdir()+'doc/'
end
