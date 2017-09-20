;+
;NAME:
;fitazza - fit function to azimuth and zenith angle
;SYNTAX: fitazza,az,za,y,fitI,weights=weights,fittype=fittype,
;                yfit=yfit,covar=covar,variance=variance,sigmaA=sigmaA,
;                singular=singular,chisq=chisq
;ARGS:
;       az[npts]    : float  azimuth in deg
;       za[npts]    : float  za in deg
;        y[npts]    : float  data to fit
;KEYWORDS:
;     weights[npts] : weights to use with fit. default = 1.
;       fittype     : int. 1..4 see below
;RETURNS:
;         fitI      : {azzafit} structure. return fitinfo here.
;       yfit[npts]  : fit values evaluated at input az,za returne here
;       covar[m,m]  : normalized covariance matrix. m=# of coef.
;    variance[m]    : of the diagnonal elements (not normalized)
;      sigmaA[m]    : sigmas of the coef (not normalized)
;       singular    : int, number of singular coef found.
;         chisq     : float. chisq
;DESCRIPTION:
;   There are 4 or 10 coefficients in the fit. The functional form depends
; on the value of fittype.
; fittype: coef: 0-3
; 1:  c0 + c1*za + c2(za-14)^2 + c3(za-14)^3 + azterms.. use za-14 when za gt 14
; 2:  c0 + c1*(za-10) + c2(za-10)^2+c3(za-10)^3 + azterms. for all za
; 3:  y=(za-10)/10 then
;     c0 +c1*(y)+ c2*(2*y*y-1.) + c3*(4*y^3-3*y) + azterms. for all za
; 4:  c0 +c1*za +c2*(za-14)^2 +c3*(za-14)^3 no azterms.. use za-14 when za gt 14
; 5:  c0 + c1*(za-10) + c2(za-10)^2+c3*(za-10)^3+
;       costerm have 1az,3az and sinza*3az.. no 2az term    
; 6:  c0 + c1*(za-10) + c2(za-10)^2+c3(za-10)^3  no az terms
; 7:  c0 +  c1*cos(az)  +c2*sin(az) + c3*cos(2az) + c4*sin(2az) 
;  c5*cos(3az) +c6*sin(3az)
;
; coef: 4-9
; az terms:
;  c4*cos(az)  +c5*sin(az) + c6*cos(2az) + c7*sin(2az) 
;  c8*cos(3az) +c9*sin(3az)
;
; The fit info is returned in the fit structure {azzafit}. It contains:
;
;            numCoef:        10L    , for fit
;            fittype:         1     , 1-def,2-about za10,3-chebyshev 3rd order
;            freq   :         0.    , Mhz
;             coef  :     dblarr(10),coef.
;         sigmaCoef :     dblarr(10), sigmas on each coef.
;             covar :  dblarr(10,10), covariance matrix
;            chisq  :         0.D   , of fit
;           sigma   :         0.D   , of fit - data
;           zaSet   :        14.    , za cutoff for higher order,or pivot
;            rfNum  :         0     , rcv num
;             pol   :         ' '   ,  a ,  b , i  stokes I
;            type   :         ' '   ,gain,sefd,tsys,etc..
;           title   :         ' '   , for any plots top
;           ytitle  :         ' '   , for any plots left
;           date    :         ' '     fit run
;
;Since the fittype is returned in the structure, later routines (fitazzaeval
;etc..) know which functional form to use.
;You must call @geninit once before calling this routine to define the
;{azzafit} structure.
;SEE ALSO:
;fitazzaeval, fitazzapr, fitazzaplres, fitazzaprcov
;-
function fitazzafunc1,x,m
    common fitazza,azc,zac
;

    zacutoff=14.
    i=long(x+.5)
    az=azc[i]
    za=zac[i]
    azrd=az*!dtor
    cosaz=cos(azrd)
    sinaz=sin(azrd)
    cos2az=cos(2.D*azrd)
    sin2az=sin(2.D*azrd)
    cos3az=cos(3.D*azrd)
    sin3az=sin(3.D*azrd)


    zap=za - zacutoff
    zap2=zap*zap
    zap3=zap2*zap
    ind=where(za le zacutoff,count)
    if count gt 0 then begin
        zap2[ind]=0.
        zap3[ind]=0.
    endif
    return,[[1.],[za],[zap2],[zap3],[cosaz],[sinaz],$
           [cos2az],[sin2az],[cos3az],[sin3az]]
end
function fitazzafunc2,x,m
    common fitazza,azc,zac
;

    zaMid=10.
    i=long(x+.5)
    az=azc[i]
    za=zac[i]-zaMid
    azrd=az*!dtor
    cosaz=cos(azrd)
    sinaz=sin(azrd)
    cos2az=cos(2.D*azrd)
    sin2az=sin(2.D*azrd)
    cos3az=cos(3.D*azrd)
    sin3az=sin(3.D*azrd)
    return,[[1.],[za],[za*za],[za*za*za],[cosaz],[sinaz],$
           [cos2az],[sin2az],[cos3az],[sin3az]]
end

function fitazzafunc3,x,m
    common fitazza,azc,zac
;
; fit to chebyshev in za
;

    i=long(x+.5)
    az=azc[i]
    zap=(zac[i]-10.)/10.            ;to scale for chebyshev -1,1 range
    azrd=az*!dtor
    cosaz=cos(azrd)
    sinaz=sin(azrd)
    cos2az=cos(2.D*azrd)
    sin2az=sin(2.D*azrd)
    cos3az=cos(3.D*azrd)
    sin3az=sin(3.D*azrd)
    return,[[1.],[zap],[2.*zap*zap-1.],[4.*zap*zap*zap-3.*zap],[cosaz],[sinaz],$
           [cos2az],[sin2az],[cos3az],[sin3az]]
end

function fitazzafunc5,x,m
    common fitazza,azc,zac
; 
    zaMid=10.
    i=long(x+.5)
    az=azc[i]
    za=zac[i]-zaMid
    azrd=az*!dtor
    cosaz=cos(azrd)
    sinaz =sin(azrd)
    cos3az=cos(3.D*azrd)
    sin3az=sin(3.D*azrd)
    sinza=sin(za*!dtor)
    return,[[1.],[za],[za*za],[za*za*za],[cosaz],[sinaz],$
           [cos3az],[sin3az],[sinza*cos3az],[sinza*sin3az]]
end
function fitazzafunc6,x,m
    common fitazza,azc,zac
;

    zaMid=10.
    i=long(x+.5)
    za=zac[i]-zaMid
    return,[[1.],[za],[za*za],[za*za*za]]
end

function fitazzafunc4,x,m
    common fitazza,azc,zac
; just fit to za

    zacutoff=14.
    i=long(x+.5)
    za=zac[i]
    zap=za - zacutoff
    zap2=zap*zap
    zap3=zap2*zap
    ind=where(za le zacutoff,count)
    if count gt 0 then begin
        zap2[ind]=0.
        zap3[ind]=0.
    endif
    return,[[1.],[za],[zap2],[zap3]]
end
function fitazzafunc7,x,m
    common fitazza,azc,zac
;

    i=long(x+.5)
    az=azc[i]
    azrd=az*!dtor
    cosaz=cos(azrd)
    sinaz=sin(azrd)
    cos2az=cos(2.D*azrd)
    sin2az=sin(2.D*azrd)
    cos3az=cos(3.D*azrd)
    sin3az=sin(3.D*azrd)
    return,[[1.],[cosaz],[sinaz],[cos2az],[sin2az],[cos3az],[sin3az]]
end


;
pro fitazza,az,za,y,fitI,yfit=yfit,covar=covar,weights=weights,$
        variance=variance,sigmaa=sigmaa,singular=singular,chisq=chisq,$
        fittype=fittype
;
common fitazza,azc,zac
    
    if n_elements(covar) eq 0 then covar=0
    if n_elements(variance) eq 0 then variance=0
    if n_elements(sigmaa) eq 0 then sigmaa=0
    if n_elements(singular) eq 0 then singular=0
    if n_elements(yfit) eq 0 then yfit=0
    if n_elements(chisq) eq 0 then chisq=0
    if n_elements(fittype) eq 0 then fittype=1
    npts=(size(az))[1]
    if n_elements(weights) eq 0 then weights=fltarr(npts)+ 1.
    fitI={azzafit}
    fitI.numCoef=10
    if (fittype eq 4) or (fittype eq 6)  then fitI.numCoef=4
    if (fittype eq 7) then fitI.numCoef=7
    azc=az
    zac=za
    x=findgen(npts)
    sigmaA=dblarr(10)
    case fittype of
        1 : fitnm='fitazzafunc1'
        2 : fitnm='fitazzafunc2'
        3 : fitnm='fitazzafunc3'
        4 : fitnm='fitazzafunc4'
        5 : fitnm='fitazzafunc5'
        6 : fitnm='fitazzafunc6'
        7 : fitnm='fitazzafunc7'
      else: message,'fitazza: fittype is 1 thru 7'
    endcase
    fitI.coef=svdfit(x,y,fitI.numCoef,chisq=chisq,sigma=sigmaA,$
            singular=singular,yfit=yfit,/double,function_name=fitnm,$
            variance=variance,covar=covar,weights=weights)
;;  print,'y:',y[0:5]
;;  print,'chisq ',chisq
;;  print,"sigmaA:",sigmaA
    fitI.chisq     = chisq
    fitI.sigmaCoef = sigmaA
    fitI.covar     = fitI.covar*0.
    n=fitI.numCoef
    fitI.covar[0:n-1,0:n-1]= covarnorm(covar)
    fitI.sigma  =(rms(y-yfit,/quiet))[1]
    fitI.date    = systime()
    case fittype of
        1: begin
        fitI.zaSet  =14.
        fitI.fittype=1
            end
        2: begin
        fitI.zaSet  =10.
        fitI.fittype=2
            end
        3: begin
        fitI.zaSet  =10.
        fitI.fittype=3
            end
        4: begin
        fitI.zaSet  =14.
        fitI.fittype=4
            end
        5: begin
        fitI.zaSet  =10.
        fitI.fittype=5
            end
        6: begin
        fitI.zaSet  =10.
        fitI.fittype=6
            end
        7: begin
        fitI.zaSet  =0.
        fitI.fittype=7
            end
    else:message,'fittype is 1thru 7'
    endcase
    return
end
