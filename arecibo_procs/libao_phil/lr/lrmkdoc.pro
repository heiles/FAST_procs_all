;
; extract documentation , create html file
;
inpd=aodefdir()+ 'lr'
outd=aodefdir(/doc) + 'lrdoc.html'
mk_html_help_ph,inpd,outd,title='distomat/laser ranging software routines',$
    bgcolor='white'

explainbuild,'lr',inpd,aodefdir()+'doc/'

end
