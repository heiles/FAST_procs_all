;
; extract documentation , create html file
;
dirIn=aodefdir() + 'agc'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'agcdoc.html',$
         title='AGC (Az,Gr,Ch) idl routines',bgcolor='white'

explainbuild,'agc',dirIn,aodefdir()+'doc/'
end
