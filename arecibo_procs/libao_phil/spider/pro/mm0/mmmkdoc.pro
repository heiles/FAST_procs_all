;
; extract documentation , create html file
;
dirIn=aodefdir() + 'spider/pro/mm0'
mk_html_help_ph,dirIn, aodefdir(/doc) + 'mmdoc.html',$
         title='spider scan calibration routines',bgcolor='white'
explainbuild,'mm',dirIn,aodefdir()+'doc/'
end

