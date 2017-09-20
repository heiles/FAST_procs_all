; $Id: curvefit.pro,v 1.19 1997/07/09 21:27:00 slett Exp $
;
; Copyright (c) 1982-1997, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;
; mods pjp..
;      added keywords:
;    flambdastep=flambdastep - when loop on non-linear iteration
;                default=10.    
;    covar=covar    return normalized covar matrix for last iteration
;    trouble=trouble added to let you know if it didn't converge and why
;
FUNCTION CURVEFITPP, x, y, weights, a, sigma, FUNCTION_NAME = Function_Name, $
                        ITMAX=itmax, ITER=iter, TOL=tol, CHI2=chi2, $
                        NODERIVATIVE=noderivative, CHISQ=chisq,$
                        FLAMBDASTEP=flambdastep,COVAR=covar,cfplot=cfplot,$
                        trouble=trouble,halfass=halfass,cfparms=cfparms,$
                        nostop=nostop
; Copyright (c) 1988-1995, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;       CURVEFITPP-phils version of curvefit with a few bug fixes.
;
; PURPOSE:
;       Non-linear least squares fit to a function of an arbitrary 
;       number of parameters.  The function may be any non-linear 
;       function.  If available, partial derivatives can be calculated by 
;       the user function, else this routine will estimate partial derivatives
;       with a forward difference approximation.
;
; CATEGORY:
;       E2 - Curve and Surface Fitting.
;
; CALLING SEQUENCE:
;       Result = CURVEFIT(X, Y, Weights, A, SIGMA, FUNCTION_NAME = name, $
;                         ITMAX=ITMAX, ITER=ITER, TOL=TOL, /NODERIVATIVE,$
;                         CHISQ=CHISQ,FLAMBDASTEP=FLAMBDASTEP,covar=covar,
;                         cfplot=cfplot,cfparms,trouble=trouble,halfass=halfass)
;
; INPUTS:
;       X:  A row vector of independent variables.  This routine does
;           not manipulate or use values in X, it simply passes X
;           to the user-written function.
;
;       Y:  A row vector containing the dependent variable.
;
;  Weights:  A row vector of weights, the same length as Y.
;            For no weighting,
;                 Weights(i) = 1.0.
;            For instrumental (Gaussian) weighting,
;                 Weights(i)=1.0/sigma(i)^2
;            For statistical (Poisson)  weighting,
;                 Weights(i) = 1.0/y(i), etc.
;
;       A:  A vector, with as many elements as the number of terms, that 
;           contains the initial estimate for each parameter.  IF A is double-
;           precision, calculations are performed in double precision, 
;           otherwise they are performed in single precision. Fitted parameters
;           are returned in A.
;
; KEYWORDS:
;       FUNCTION_NAME:  The name of the function (actually, a procedure) to 
;       fit.  IF omitted, "FUNCT" is used. The procedure must be written as
;       described under RESTRICTIONS, below.
;
;       ITMAX:  Maximum number of iterations. Default = 20.
;       ITER:   The actual number of iterations which were performed
;       TOL:    The convergence tolerance. The routine returns when the
;               relative decrease in chi-squared is less than TOL in an 
;               interation. Default = 1.e-3.
;       CHI2:   The value of chi-squared on exit (obselete)
;     
;       CHISQ:   The value of reduced chi-squared on exit
;       NODERIVATIVE:   IF this keyword is set THEN the user procedure will not
;               be requested to provide partial derivatives. The partial
;               derivatives will be estimated in CURVEFIT using forward
;               differences. IF analytical derivatives are available they
;               should always be used.
;pjp  flambdastep: This method moves between a steepest descent and the
;               inverse hessian method (using the curvature matrix to 
;               compute the answer when we are close to the solution).
;pjp  trouble   : 0 converged ok
;                -1 chisq infinite
;                -2 flambdacount > 30 * 10/flambdastep
;                -3 iteration > itermax .default 20
;                -4 alpha/c not finite
;pjp  nostop    : if set then don't stop if alpha/c not finite, just return
;                 with trouble set
;pjp  halfass   : 0..1. multiply step by this amount to slow down motion
;pjp  cfparms   : if set then print parameters input to fit
;pjp  cfplot    : 0 no plot, 
;                 1 plot no wait
;                 2 plot  wait at last on fit
;                 3 plot  wait each one
;
; OUTPUTS:
;       Returns a vector of calculated values.
;       A:  A vector of parameters containing fit.
;
; OPTIONAL OUTPUT PARAMETERS:
;       Sigma:  A vector of standard deviations for the parameters in A.
;
; COMMON BLOCKS:
;       NONE.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       The function to be fit must be defined and called FUNCT,
;       unless the FUNCTION_NAME keyword is supplied.  This function,
;       (actually written as a procedure) must accept values of
;       X (the independent variable), and A (the fitted function's
;       parameter values), and return F (the function's value at
;       X), and PDER (a 2D array of partial derivatives).
;       For an example, see FUNCT in the IDL User's Libaray.
;       A call to FUNCT is entered as:
;       FUNCT, X, A, F, PDER
; where:
;       X = Variable passed into CURVEFIT.  It is the job of the user-written
;           function to interpret this variable.
;       A = Vector of NTERMS function parameters, input.
;       F = Vector of NPOINT values of function, y(i) = funct(x), output.
;       PDER = Array, (NPOINT, NTERMS), of partial derivatives of funct.
;               PDER(I,J) = DErivative of function at ith point with
;               respect to jth parameter.  Optional output parameter.
;               PDER should not be calculated IF the parameter is not
;               supplied in call. IF the /NODERIVATIVE keyword is set in the
;               call to CURVEFIT THEN the user routine will never need to
;               calculate PDER.
;
; PROCEDURE:
;       Copied from "CURFIT", least squares fit to a non-linear
;       function, pages 237-239, Bevington, Data Reduction and Error
;       Analysis for the Physical Sciences.  This is adapted from:
;       Marquardt, "An Algorithm for Least-Squares Estimation of Nonlinear
;       Parameters", J. Soc. Ind. Appl. Math., Vol 11, no. 2, pp. 431-441,
;       June, 1963.
;
;       "This method is the Gradient-expansion algorithm which
;       combines the best features of the gradient search with
;       the method of linearizing the fitting function."
;
;       Iterations are performed until the chi square changes by
;       only TOL or until ITMAX iterations have been performed.
;
;       The initial guess of the parameter values should be
;       as close to the actual values as possible or the solution
;       may not converge.
;
;pjp Notes: This method moves between a steepest descent (move in the
;           direction of decreasing chisq using the gradient of chisq
;           with respect to the ai) and the
;               inverse hessian method (using the curvature matrix to 
;               compute the answer when we are close to the solution).
;           The value Lambda added to the diagonol elements of the
;           hessian matrix moves you between these 2 modes. When 
;           lambda is large then the diagonal elements become dominant
;           and the motion matrix solution is just the gradient motion.
;           When lambda becomes small then the of diagonal terms become
;           important and you are solving the curvature matrix.
;       flambdastep determines how fast you move between these two
;       solution methods. When things get worse, lambda is increased by
;       a factor of flambdastep and you move towards the linear descent.
;       when things get better, then lambda decreases by flambdastep and
;       you move towards solving the curvature matrix.
;   
;       note that in both instances the input data array is the
;       difference between the input data and the current fit value.
;   
;   NOTATION;
;       let i=0-npts-1
;       let m=0-nparams
;       delta:i = y(i) - yfit(i)   i=0,npts-1
;       pder:i,m= dByda:m  at y(i)
;       alpha = transpose(pder) # ((Weights # (fltarr(nterms)+1))*pder)
;       alpha:m,n=  sum:i( pder:m,i * ( 1/sig^2:i * pder:i,n)
;       so this is the hessian matrix with sig^2 included..
;       beta:m  = sum:i(delta:i # pder:i,m) linear step for correction
;
;                 sum deriv of each a:m over all y(i)i
;       alpha is the hessian matrix
;       b=beta is the current error in the fit.
;
; EXAMPLE:  Fit a function of the form f(x) = a * exp(b*x) + c to
;           sample pairs contained in x and y.
;           In this example, a=a(0), b=a(1) and c=a(2).
;           The partials are easily computed symbolicaly:
;           df/da = exp(b*x), df/db = a * x * exp(b*x), and df/dc = 1.0
;
;           Here is the user-written procedure to return F(x) and
;           the partials, given x:
;
;       pro gfunct, x, a, f, pder      ; Function + partials
;         bx = exp(a(1) * x)
;         f= a(0) * bx + a(2)         ;Evaluate the function
;         IF N_PARAMS() ge 4 THEN $   ;Return partials?
;         pder= [[bx], [a(0) * x * bx], [replicate(1.0, N_ELEMENTS(f))]]
;       end
;
;         x=findgen(10)                  ;Define indep   dep variables.
;         y=[12.0, 11.0,10.2,9.4,8.7,8.1,7.5,6.9,6.5,6.1]
;         Weights=1.0/y            ;Weights
;         a=[10.0,-0.1,2.0]        ;Initial guess
;         yfit=curvefit(x,y,Weights,a,sigma,function_name='gfunct')
;         print, 'Function parameters: ', a
;         print, yfit
;       end
;
; MODIFICATION HISTORY:
;       Written, DMS, RSI, September, 1982.
;       Does not iterate IF the first guess is good.  DMS, Oct, 1990.
;       Added CALL_PROCEDURE to make the function's name a parameter.
;              (Nov 1990)
;       12/14/92 - modified to reflect the changes in the 1991
;            edition of Bevington (eq. II-27) (jiy-suggested by CreaSo)
;       Mark Rivers, U of Chicago, Feb. 12, 1995
;           - Added following keywords: ITMAX, ITER, TOL, CHI2, NODERIVATIVE
;             These make the routine much more generally useful.
;           - Removed Oct. 1990 modification so the routine does one iteration
;             even IF first guess is good. Required to get meaningful output
;             for errors. 
;           - Added forward difference derivative calculations required for 
;             NODERIVATIVE keyword.
;           - Fixed a bug: PDER was passed to user's procedure on first call, 
;             but was not defined. Thus, user's procedure might not calculate
;             it, but the result was THEN used.
;
;      Steve Penton, RSI, June 1996.
;            - Changed SIGMAA to SIGMA to be consistant with other fitting 
;              routines.
;            - Changed CHI2 to CHISQ to be consistant with other fitting 
;              routines.
;            - Changed W to Weights to be consistant with other fitting 
;              routines.
;            _ Updated docs regarding weighing.
;           
;-
        common colph,decomposedph,colph

        ON_ERROR,2              ;Return to caller IF error

       ;Name of function to fit

       lastIterConverge=0           ;pjp .. after we converge try it once more
       trouble=0                    ;pjp no trouble yet
       IF n_elements(function_name) LE 0 THEN function_name = "FUNCT"
       if n_elements(halfass) eq 0 then halfass=1.d

       IF n_elements(tol) EQ 0 THEN tol = 1.D-3      ;Convergence tolerance
       IF n_elements(itmax) EQ 0 THEN itmax = 20     ;Maximum # iterations
       IF n_elements(flambdastep) EQ 0 THEN flambdastep=10.
       IF n_elements(cfplot) EQ 0 THEN cfplot=0
       maxlambdacount= 30 * fix((10./flambdastep)+.5) ;pjp

       type = size(a)
       type = type[type[0]+1]
       double = type EQ 5

       IF (type ne 4) AND (type ne 5) THEN a = float(a)  ;Make params floating

       ; IF we will be estimating partial derivatives THEN compute machine
       ; precision

       IF keyword_set(NODERIVATIVE) THEN BEGIN
          res = machar(DOUBLE=double)
          eps = sqrt(res.eps)
       ENDIF

       nterms = n_elements(a)         ; # of parameters
       nfree = n_elements(y) - nterms ; Degrees of freedom

       IF nfree LE 0 THEN message, 'Curvefit - not enough data points.'

       if keyword_set(cfparms) then begin
        ln=string(format=$
'("tol:",f6.4," hass:",f4.2," flStp:",f5.1," maxLdcnt:",i3," maxIter:",i3)',$
        tol,halfass,flambdastep,maxlambdacount,itmax)
        print,ln
       endif 

       flambda = 0.001D 
       diag = lindgen(nterms)*(nterms+1) ; Subscripts of diagonal elements

;      Define the partial derivative array

       IF double THEN pder = dblarr(n_elements(y), nterms) $
       else pder = fltarr(n_elements(y), nterms) 
;
       FOR iter = 1, itmax DO BEGIN      ; Iteration loop

;         Evaluate alpha and beta matricies.

          IF keyword_set(NODERIVATIVE) THEN BEGIN

;            Evaluate function and estimate partial derivatives
             CALL_PROCEDURE, Function_name, x, a, yfit

             FOR term=0, nterms-1 DO BEGIN

                p = a       ; Copy current parameters

                ; Increment size for forward difference derivative
                inc = eps * abs(p[term])    
                IF (inc EQ 0.) THEN inc = eps
                    p[term] = p[term] + inc
                    CALL_PROCEDURE, function_name, x, p, yfit1
                    pder[0,term] = (yfit1-yfit)/inc
             ENDFOR
          ENDIF ELSE BEGIN

             ; The user's procedure will return partial derivatives
             call_procedure, function_name, x, a, yfit, pder 

          ENDELSE

          IF nterms EQ 1 THEN pder = reform(pder, n_elements(y), 1)

          beta = ((y-yfit)*Weights) # pder
          alpha = transpose(pder) # ((Weights # (fltarr(nterms)+1))*pder)
          ii=where(finite(alpha) eq 0,count)
          if   count gt 0 then begin
             print,'curvefit, alpha not finite'
           endif

          ; save current values of return parameters

          sigma1 = sqrt( 1.0 / alpha[diag] )           ; Current sigma.
          sigma  = sigma1

;;        print,'1.in curvefit after fit. a:,b'
;;        print,a
;;        plot,x,y & oplot,x,yfit,color=2
;         stop

          chisq1 = total(Weights*(y-yfit)^2)/nfree     ; Current chi squared.
          chisq = chisq1

          yfit1 = yfit                                 

          done_early = chisq1 LT total(abs(y))/1e7/NFREE 
          IF done_early THEN begin
            GOTO, done
          endif

;
;       normalization for hessian matrix to diag before we add fractional lambda
;
          c = sqrt(alpha[diag])
          c = c # c
;
;       Given a current value for A, we compute a new value in the current
;       regime (max descent or inverse hessian depending on the current
;       value of lambda). The looping condition is:
;           while (chisq worse and loopcount < maxlambdaloopcount)
;               increase flambda by flambda step.
;              -maxlambdacount should be large enough to move us from 
;               hessian mode back out to maxdescent mode. The rate that
;               we change from hessian to maxDescent is determined by
;               flambdastep. It is setup so that the maxlambdacount is
;                30  for an flambda step of 10.
;              -If we exit this loop without finding a better chisq then
;               there is no direction to move (using the gradient) to 
;               improve chisq. so we are at a max or min with a lousy
;               chisq --> the model doesn't fit the data.
;           endwhile
;       If we do get a better chisq, we exit the loop. If chisq has not 
;       changed since the last time by much, then we're done (mimima).
;       If it is still changing, then we decrease flambda by flambdastep
;       and keep looping on maxiter. We are moving towards hessian solution
;       with the new values of Ai
;       
          lambdaCount = 0

          REPEAT BEGIN

             lambdaCount = lambdaCount + 1

             ; Normalize alpha to have unit diagonal.

             array = alpha / c
             ii=where(finite(array) eq 0,count)
             if count ne 0 then begin
                trouble=-4
                 if keyword_set(nostop) then return,yfit
                 print,'curvefit, array=alpha/c not finite' 
                 return,yfit
             endif

             ; Augment the diagonal. this is our next guess it will be 
             ; max descent or inverse hessian depending on the magnitude of
             ; lambda

             array[diag] = array[diag]*(1.+flambda) 

             ; Invert modified curvature matrix to find new parameters.

             IF n_elements(array) EQ 1 THEN array = (1.0 / array) $
             ELSE array = invert(array)
             ii=where(finite(array)  eq 0,count)
             if count ne 0 then begin
                 print,'curvefit, invert(array) not finite'
             endif
;
;           solving:
;           delta * alpha = beta.. array/c = alpha inverse, b-a=delta
;           

             b = a + (array/c # transpose(beta) ) * halfass   ; New params
             ii=where(finite(b) eq 0,count)
             if count ne 0 then begin
                 print,'curvefit, b not finite'
             endif

             call_procedure, function_name, x, b, yfit  ; Evaluate function
             chisq = total(Weights*(y-yfit)^2)/nfree    ; New chisq
             ind=where(finite(yfit) eq 0,count)
;            print,'after call_procedure, inf numbers:',count
;            stop
             sigma = sqrt(array[diag]/alpha[diag])      ; New sigma
             if keyword_set(cfplot) then begin 
                plot,x,y,/ystyle,/xstyle,psym=-2
                oplot,x,yfit,color=colph[5]
                ln=string(format=$
'("chisqN,chisq1,ratio:",f8.3,f9.3,g10.4," flmbda,cnt",G10.2,i3," iter:",i2)',$
                chisq,chisq1,(chisq1-chisq)/chisq1,flambda,lambdaCount,iter)
                print,ln
                npp=(size(a))[1]
                ln=string(format='("a0-5:",6(f11.3," "))',$
                        a[0],a[1],a[2],a[3],a[4],a[5])
                print,ln
                ln=string(format='("b0-5:",6(f11.3," "))',$
                        b[0],b[1],b[2],b[3],b[4],b[5])
                print,ln
                case 1 of 
                    npp ge 12: begin
                    ln=string(format='("a...:",6(f11.3," "))',$
                        a[6],a[7],a[8],a[9],a[10],a[11])
                    print,ln
                    ln=string(format='("b...:",6(f11.3," "))',$
                        b[6],b[7],b[8],b[9],b[10],b[11])
                    print,ln
                    end
                    npp ge 9: begin
                    ln=string(format='("a...:",3(f11.3," "))',$
                        a[6],a[7],a[8])
                    print,ln
                    ln=string(format='("b...:",3(f11.3," "))',$
                        b[6],b[7],b[8])
                    print,ln
                    end
                else: begin  ;
                      end
                endcase
                if cfplot gt 2 then begin
                    test=' '
                    read,'xmit to continue',test
                endif
              endif

             IF (finite(chisq) EQ 0) OR $
                  (lambdaCount GT maxlambdacount AND chisq GE chisq1) THEN BEGIN

                ; Reject changes made this iteration, use old values.
                case 1 of 
                    finite(chisq eq 0):trouble=-1
                    else:trouble=-2
                endcase
                if cfplot ne 0 then begin
                    plot,x,y,/ystyle,/xstyle,psym=-2
                    oplot,x,yfit,color=colph[2]
                    if cfplot ne 1 then begin
                        test=' '
                        read,'xmit to continue',test
                    endif
                endif
                message, 'Failed to converge (1)', /INFORMATIONAL
;               stop

                yfit  = yfit1
                sigma = sigma1
                chisq = chisq1
                GOTO, done 

             ENDIF             

            flambda = flambda*flambdastep     ; Assume fit got worse<pjp>

          ENDREP UNTIL chisq LE chisq1

         flambda =flambda/(flambdastep*flambdastep);<pjp>move toward hessianmode

          a=b                                    ; Save new parameter estimate.

          IF (((chisq1-chisq)/chisq1) LE tol)  THEN begin
            if lastIterConverge then begin
                GOTO,done   ;Finished?
            endif else begin
                lastIterConverge=1          ; so next time around we kick out
            endelse
          endif else begin
            lastIterConverge=0
          endelse
       ENDFOR                        ;iteration loop
;
       trouble=-3
       MESSAGE, 'Failed to converge. iter>itmax', /INFORMATIONAL

;
done:  chi2 = chisq         ; Return chi-squared (chi2 obsolete-still works)
       IF done_early THEN iter = iter - 1
       if n_elements(array) gt 0 then begin
        covar=array
       endif else begin
        covar=''    
       endelse
       if (cfplot ne 0) then begin
            plot,x,y,/ystyle,/xstyle,psym=-2
            oplot,x,yfit,color=colph[3]
            if cfplot ne 1 then begin
                    test=' '
                    read,'xmit to continue',test
            endif
        endif
       return,yfit          ; return result
END
