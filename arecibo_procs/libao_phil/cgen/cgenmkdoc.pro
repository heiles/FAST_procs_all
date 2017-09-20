;
; extract documentation , create html file
;
dirIn=aodefdir() + 'cgen'
mk_html_help_ph,dirIn,$
        aodefdir(/doc) +  'cgendoc.html',$
         title='Cummings generator routines',bgcolor='white'
explainbuild,'cgen',dirIn,aodefdir()+'doc/'
end
