;+
;NAME:
;pdevinplpf - input lowpass filter coef from disk
;SYNTAX: istat=pdevinplpf(filebase,filter)
;ARGS:
;filebase: string : basename for filter. Do not include the .0,.1,.2...
;RETURNS:
;istat  : int     : 0 ok, -1 error
;filt[] : int     filter read in. It will be the symmetric about the center.
;DESCRIPTION:
;   Read in a hires low pass filter. Pass in the basename for the
;filter (eg: 'dlpf.0032'). Don't include the .0,.1,.2,.3 .
;Program will input the filter, symmeterize, and then return it.
;
;-
function pdevinplpf,filebase,filt
;
;   input
numint=0
for i=0,3 do begin
    fn=string(format='(a,".",i1)',filebase,i)
    openr,lun,fn,/get_lun
    if i eq 0 then begin
       fs=fstat(lun); 
       size=fs.size
       dec=(size/5)   ; 4 char and linefeed each number
       filt=intarr(dec,4,2)
       filt1=intarr(dec)
    endif
    for ii=0 , dec-1 do begin
        readf,lun,format='(z4)',numint
        filt[ii,3-i,1]=numint
    endfor
    free_lun,lun
endfor
filt=reform(filt,dec*4,2)
filt[*,0]=reverse(reform(filt[*,1]))
filt=reform(filt,dec*8)
return,0
end
