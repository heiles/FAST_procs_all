;+
;NAME:
;fitazzalog - write fitazza info in tabular form to a file
;SYNTAX: fitazzalog,fitI,lun,calval,calval2,title=title
;ARGS  :
;       fitI:   {azzafit} structure holding info returned from fitazza.
;        lun:  int    the lun open to the file for output.
;     calval:  float  the cal value that was used in the fit.
;     calval2: float  2nd cal value if fit was to stokes I
;KEYWORDS:
;        title:   string, title to write in file.
;DESCRIPTION
;   Print out the fit values returned from fitazza in tabular form to a file.
;You should open the file for write access (maybe append if you don't 
;want to overwrite the file).
;SEE ALSO:
;fitazza, fitazzapr, fitazzaeval
;-
pro fitazzalog,fitI,fd,calVal1,calval2,title=title
; 
;frq typ  c0          za          (za-14)^2  (za-14)^3    cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal
;frq typ  c0          za-10       (za-10)^2  (za-10)^3    cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal
;frq typ  c0          y           2*y^2-1     4*y^3-3*y   cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal
;1405. 3  8.9220e+00 -1.1083e-01  2.1392e-03 -3.4151e-03  4.1611e-01  1.8207e-01 -1.0120e-01  2.7404e-02 -3.0386e-01 -1.4610e-01  2.5573e-01 a   1.850

    if n_elements(fd) eq 0 then fd=-1
    if keyword_set(title) then begin
        nelm=n_elements(title)
        for i=0,nelm-1 do begin
            printf,fd,";"+title[i]
        endfor
        case fitI.fittype of
            1: begin
        printf,fd,$
';frq typ c0          za          (za-14)^2  (za-14)^3    cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal'
               end
            2: begin
        printf,fd,$
';frq typ c0          za-10       (za-10)^2  (za-10)^3    cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal'
               end
            3: begin
        printf,fd,$ 
'> let y=(za-10.)/10. then
        printf,fd,$
';frq typ c0          y           2*y^2-1     4*y^3-3*y   cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal'
              end
            4: begin
        printf,fd,$
';frq typ c0          za          (za-14)^2  (za-14)^3    sigma     pol calVal'
               end
            6: begin
        printf,fd,$
';frq typ c0          za-10        (za-10)^2  (za-10)^3    sigma     pol calVal'
               end
            7: begin
        printf,fd,$
';frq typ c0          cosAz       sinAz       cos2Az      sin2az      cos3az      sin3az      sigma     pol calVal'
               end
        else: message,'fitazzalog, fittype is 1-7'
    endcase
    endif 
    calvalo=''
    if (n_elements(calval1) ne 0 )then calvalo=string(format='(g5.3)',calval1)
    if (n_elements(calval2) ne 0 )then calvalo=calvalo+string(format='(" ",g5.3)',calval2)
;   print,calvalo
    if (fitI.fittype eq 4) or (fitI.fittype eq 6) then begin

    ln=string(format='(f5.0,i3,5(" ",e11.4)," ",a1,"  ",a)', $
        fitI.freq,fitI.fittype,fitI.coef[0],fitI.coef[1],fitI.coef[2],$
        fitI.coef[3],fitI.sigma,fitI.pol,calValo)
    endif else begin
       if (fitI.fittype eq 7) then begin
    ln=string(format='(f5.0,i3, 8(" ",e11.4)," ",a1,"  ",a)', $
        fitI.freq,fitI.fittype,fitI.coef[0],fitI.coef[1],fitI.coef[2],$
        fitI.coef[3],fitI.coef[4],fitI.coef[5],fitI.coef[6],$
        fitI.sigma,fitI.pol,calValo)
	   endif else begin
    ln=string(format='(f5.0,i3,11(" ",e11.4)," ",a1,"  ",a)', $
        fitI.freq,fitI.fittype,fitI.coef[0],fitI.coef[1],fitI.coef[2],$
        fitI.coef[3],fitI.coef[4],fitI.coef[5],fitI.coef[6],fitI.coef[7],$
        fitI.coef[8],fitI.coef[9],fitI.sigma,fitI.pol,calValo)
    	endelse
	endelse
    printf,fd,ln
    return
end
