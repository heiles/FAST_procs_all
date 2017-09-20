;
; extract documentation , create html file
;
dirIn=aodefdir() + 'im/new'
outd= aodefdir(/doc) + 'imdoc.html'
mk_html_help_ph,dirIn,outd,title='interference monitoring idl routines',$
    bgcolor='white'
explainbuild,'im',dirIn,aodefdir()+'doc/'
end

