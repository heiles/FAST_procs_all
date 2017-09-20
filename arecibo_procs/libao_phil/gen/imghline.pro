;+
;NAME:
;imghline - draw horizontal line on an image 
;SYNTAX: imghline,img,linind,dashlen,vlines,val,ononly=ononly
;  ARGS:  
;   img[n,m] : float    image to display
;   linind[k]: int   vertical indices into img array for horizontal lines 
;                    (count from 0)
;   dashlen  : int  number of pixels for on dash. 
;   vlines   : int  number of vertical lines for each dash. def:1
;   val      : float value to use for dash.
;DESCRIPTION:
;   Draw horizontal dashed lines into a 2d image array. By default the
;dashes are 4 pixels on, 4 pixels off. You can change the length with
;dashlen. The only requirement is that dashlen must divide into the
;first dimension of the img array.  The dashes will be 1 horizontal line
;thick. You can make them wider with the vlines keyword. This is sometimes
;necessary if the image is being scaled down on display). 
;-   
pro imghline,img,linind,dashlen,vlines,val,ononly=ononly

if n_elements(ononly) eq 0 then ononly=0
if n_elements(vlines) eq 0 then vlines=1
if n_elements(val)    eq 0 then val=255
xl=(size(img))[1]
if n_elements(dashlen) eq 0 then dashlen=xl/(4)
nl=(xl/(dashlen*2)) * dashlen*2
xx=lindgen(vlines) - vlines/2
x=fltarr(nl)
x=reform(x,dashlen,2,nl/(dashlen*2))
x[*,0,*]=val
jj=(ononly)?where(x eq val):lindgen(nl)
ii=lindgen(nl)
for i=0,n_elements(linind)-1 do begin
    for j=0,vlines-1 do begin
        k=xx[j]+linind[i]
        img[ii[jj],k]=x[jj]
    endfor
endfor
return
end
