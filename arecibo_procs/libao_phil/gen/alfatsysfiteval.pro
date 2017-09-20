;
;
;
;y= a0          + a1*za     + a2*(za-cutoff)^2 + a3*cos(az) + a4*cos(za) +
;   a5*cos(2az) + a6*cos2az + a7*cos2rot       + a8*sin2rot + a9*(freqGhz-foff)
;  a10*(freqGhz-freqOff)^2
;
function alfatsysfiteval,fittype,az,za,freqGhz,rota,coef

    freqOff=1.36
    zacutoff=14
    i=0
    n=n_elements(az)
    case fittype of 
        1 : begin
;
;  a0 + za
        y=coef[i] + coef[i+1]*za            ; linear za
        i=i+2
;
;       (za-cutoff)^2 > cutoff
;
        ind=where(za ge zacutoff,count)
        if count gt 0 then y[ind]=y[ind] + coef[i]*(za[ind]-zacutoff)^2 
        i=i+1
;
;       cosaz, sinaz
;
        y=y + coef[i]*cos(1D*(az)*!dtor) + coef[i+1]*sin(1D*(az)*!dtor)
        i=i+2
;
;       cos2az, sin2az
;
        y=y + coef[i]*cos(2D*az*!dtor) + coef[i+1]*sin(2D*az*!dtor)
        i=i+2
;
;       cos2rot, sin2rot
;
        y=y + coef[i]*cos(2D*rota*!dtor) + coef[i+1]*sin(2D*rota*!dtor)
        i=i+2

;
;   freq + freq^2 
;
        ff=freqGhz-freqOff
        y=y +  ff*(coef[i] + ff*coef[i+1])
        i=i+2
        end
;
;   no az dependence
;
    2: begin
;
;  a0 + za
;
        y=coef[i] + coef[i+1]*za            ; linear za
        i=i+2
;
;       (za-cutoff)^2 > cutoff
;
        ind=where(za ge zacutoff,count)
        if count gt 0 then y[ind]=y[ind] + coef[i]*(za[ind]-zacutoff)^2
        i=i+1
;
;   freq + freq^2
;
        ff=freqGhz-freqOff
        y=y +  ff*(coef[i] + ff*coef[i+1])
        i=i+2
        end
   else: message,"fittype if 1 or 2"
   endcase
    return,y
end
