;+
;NAME:
;printpath - print out the path variable
;SYNTAX: printpath
;ARGS:  none 
;DESCRIPTION:
;   print out the path system variable one path per line. The order is the
;order they appear in the path variable.
;-
pro printpath
;
; cut newpath from path variable. must enter full path
;
a=strsplit(!path,":",/extract)
n=n_elements(a)
for i=0,n-1 do print,a[i]
return
end
