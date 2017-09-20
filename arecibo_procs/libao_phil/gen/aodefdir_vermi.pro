;+
;NAME:
;aodefdir - AO base directory for idl routines.
;
;SYNTAX: defdir=aodefdir(doc=doc,url=url)
;
;ARGS:
;   doc:    if the keyword is set then return the directory for the 
;           html documentation.
;   url:    if the keyword is set then return the url for the 
;           html documentation.
;
;DESCRIPTION:
;   Return the directory where the ao idl routines are stored. At AO it 
;returns '/pkg/rsi/local/libao/phil/'. The addpath() routine will use this
;directory if no pathname is given. This routine makes it easier
;to export the ao idl procedures to other sites.
;-

function aodefdir,doc=doc,url=url, vermi=vermi, vermu=vermu
         if keyword_set(doc) then return,'/home/phil/public_html/'
         if keyword_set(url) then return,'http://www.naic.edu/~phil/'
;         return,'/pkg/rsi/local/libao/phil/'
;for vermu:
;         return, '/home/heiles/dzd4/heiles/arecibo/procs/libao_phil/'
;for vermi:
         return,'/dzd4/heiles/arecibo/procs/libao_phil/'
end
