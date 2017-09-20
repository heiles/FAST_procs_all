;
; extract documentation , create html file
;
dirIn=aodefdir() + 'scrm'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) + 'scrmdoc.html',$
         title='Access scramnet logfiles (agc,pnt)',bgcolor='white'

explainbuild,'scrm',dirIn,aodefdir()+'doc/'
end
