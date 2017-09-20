;
; extract documentation , create html file
;
dirIn=aodefdir() + 'Cor2/cormap'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'cormapdoc.html',$
         title='correlator mapping idl routines',bgcolor='white'

explainbuild,'cormap',dirIn,aodefdir()+'doc/' 
end
