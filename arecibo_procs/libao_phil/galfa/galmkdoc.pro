;
; extract documentation , create html file
;
dirIn=aodefdir() + 'galfa'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'galdoc.html',$
         title='galfa  idl routines',bgcolor='white'
explainbuild,'gal',dirIn,aodefdir()+'doc/'
end
