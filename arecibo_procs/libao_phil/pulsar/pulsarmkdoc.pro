;
; extract documentation , create html file
;
dirIn=aodefdir() + 'pulsar'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'pulsardoc.html',$
         title='pulsar related idl routines',bgcolor='white'

explainbuild,'pulsar',dirIn,aodefdir()+'doc/' 
end
