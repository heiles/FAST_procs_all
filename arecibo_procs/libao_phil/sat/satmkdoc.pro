;
; extract documentation , create html file
;
dirIn=aodefdir() + 'sat'
mk_html_help_ph,dirIn,$
        aodefdir(/doc)+'satdoc.html',$
         title='satellite prediction routines',bgcolor='white'

explainbuild,'sat',dirIn,aodefdir()+'sat/' 
end
