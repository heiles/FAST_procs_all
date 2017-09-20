;+
;NAME:
;fitsin - fit to Asin(Nx-phi) where N=1 to 6. or 123
;SYNTAX:result=fitsin(x,y,N,cossin=cossin)
;ARGS:
;       x  - independent var. (x values for fit). should already be in radians
;       y  - measured dependent variable.
;       N  - 1..6 .. integral  period to fit . 1 to 6.
;          - 123 . fit 1,2,3 az terms at once
;KEYWORDS:
;	cossin: 	if set then return amplitudes of cos,sin rather then sin,phase
;RETURN:
;   result[]: float
;            [0] constant coefficient
;            [1] amplitude
;            [2] phase in radians
;   If cossin is set then return:
;            [0] constant coefficient
;            [1] amplitude cosine
;            [2] amplitude sin
; if n=123 then:
;            [0]     constant
;            [1,2]   amp,phase 1 az
;            [3,4]   amp,phase 2 az
;            [5,6]   amp,phase 3 az
;DESCRIPTION:
;   Do a linear least squares fit (svdfit) to a sin wave with integral
;values of the frequency (1 through 6 are allowable values). It also
; supports simultaneous fit for 1,2,3az.
;Returns the coefficients of the fit.
;
;NOTES:   
; Asin(Nt-phi)= Asin(Nt)cos(phi) - Acos(Nt)sin(phi) =  Bsin(Nt) + Ccos(Nt)
;      B=Acos(phi)
;      C=-Asin(phi)
;    phi      = atan(sin(phi)/cos(phi))/ = atan(-c,b)
;    amplitude=sqrt(B^2+C^2)
; so the fit for B,C is linear.
;
; result from svd:
;  a[0] - constant
;  a[1] - sin coef
;  a[2] - cos coef
;
;-           
;  
;   here are the function to evaluate
;
function fitsin1,x,m
    return,[[1.],[sin(x)],[cos(x)]]
end
function fitsin2,x,m
    return,[[1.],[sin(2.*x)],[cos(2.*x)]]
end
function fitsin3,x,m
    return,[[1.],[sin(3.*x)],[cos(3.*x)]]
end
function fitsin4,x,m
    return,[[1.],[sin(4.*x)],[cos(4.*x)]]
end
function fitsin5,x,m
    return,[[1.],[sin(5.*x)],[cos(5.*x)]]
end
function fitsin6,x,m
    return,[[1.],[sin(6.*x)],[cos(6.*x)]]
end
function fitsin123,x,m
    return,[[1.],[sin(x)],[cos(x)],$
                 [sin(2.*x)],[cos(2.*x)],$
                 [sin(3.*x)],[cos(3.*x)]]
end
function fitsin13,x,m
    return,[[1.],[sin(x)],[cos(x)],$
                 [sin(3.*x)],[cos(3.*x)]]
end
;
; fitsin function
;
function fitsin,x,y,N,cossin=cossin
;
;   could not seem to embed quote in the string 
    strn=string(format='(I0)',N)
	lparms=string(format='(i0)',(n eq 123)?7:(n eq 13)?5:3)
    str="a=svdfit(x,y,"+lparms+",function_name='fitsin"+strn+"',singular=sng)"
    sng=0
    z=execute(str)
    if z eq 0  then message,"couldn't compile request.. n can be 1..6, or 123 "
;
    if  sng ne 0 then  message,"svdfit returned singularity"
	if keyword_set(cossin) then begin
		case n of
		123: begin
					return,[a[0],$
					a[2],a[1],$
					a[4],a[3],$
					a[6],a[5]]
			 end
		13:   begin
					return,[a[0],$
					a[2],a[1],$
					a[4],a[3]]
			 end
		else: begin 
			  return,[a[0],a[2],a[1]]
			  end
		endcase
	endif

; go 0 to pi
	if n le 6 then begin
    	ph=(atan(-a[2],a[1]))
    	if ph lt 0 then ph=ph+ 2*!pi
    	amp=sqrt(a[1]*a[1]+a[2]*a[2])
    	return,[a[0],amp,ph]
	endif else begin
		case n of
			123: begin
    			ph1=(atan(-a[2],a[1]))
    			if ph1 lt 0 then ph1=ph1+ 2*!pi
    			amp1=sqrt(a[1]*a[1]+a[2]*a[2])
    			ph2=(atan(-a[4],a[3]))
    			if ph2 lt 0 then ph2=ph2+ 2*!pi
    			amp2=sqrt(a[4]*a[4]+a[3]*a[3])
    			ph3=(atan(-a[6],a[5]))
    			if ph3 lt 0 then ph3=ph3+ 2*!pi
    			amp3=sqrt(a[6]*a[6]+a[5]*a[5])
				return,[a[0],amp1,ph1,amp2,ph2,amp3,ph3]
				end
			13: begin
				   ph1=(atan(-a[2],a[1]))
                   if ph1 lt 0 then ph1=ph1+ 2*!pi
                   amp1=sqrt(a[1]*a[1]+a[2]*a[2])
                   ph3=(atan(-a[4],a[3]))
                   if ph3 lt 0 then ph3=ph3+ 2*!pi
                   amp3=sqrt(a[4]*a[4]+a[3]*a[3])
                return,[a[0],amp1,ph1,amp3,ph3]
				end
			else: begin
				print,"valid fit req:1-6,123,13"
			    return,0
			    end
		endcase
	endelse
end
