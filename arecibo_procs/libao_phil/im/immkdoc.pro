;
; extract documentation , create html file
;
;mk_html_help,'/home/aosun/u4/phil/idl/im',$
dirIn=aodefdir() + "im"
sources=aodefdir() +  ['im/im1img.pro','im/immosimg1frq.pro']
outd= aodefdir(/doc) + 'imdoc.html'
mk_html_help_ph,sources,outd,title='interference monitoring idl routines',$
    bgcolor='white'
explainbuild,"im",dirIn,aodefdir() + 'doc/'
end

