;
; extract documentation , create html file
;
inpd=aodefdir()+ 'td'
outd=aodefdir(/doc) + 'tddoc.html'
mk_html_help_ph,inpd,outd,title='tiedown software routines',$
    bgcolor='white'

explainbuild,'td',inpd,aodefdir()+'doc/'

end
