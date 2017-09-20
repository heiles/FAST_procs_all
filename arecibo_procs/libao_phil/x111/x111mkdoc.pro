;
; extract documentation , create html file
;
dirIn=aodefdir() + 'x111'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'x111doc.html',$
         title='x111 idl routines',bgcolor='white'

explainbuild,'x111',dirIn,aodefdir()+'doc/' 
end
