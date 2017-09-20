;
; extract documentation , create html file
;
dirIn=aodefdir() + 'gen/pnt'
outd=aodefdir(/doc) + 'pntdoc.html'
mk_html_help_ph,dirIn,outd,$
    title='ao pointing related idl routines',$
        bgcolor='white'

explainbuild,'pnt',dirIn,aodefdir()+'doc/'
end
