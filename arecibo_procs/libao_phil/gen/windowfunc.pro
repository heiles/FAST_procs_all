;+
;NAME:
;windowfunc - make a window function
;SYNTAX: val=windowfunc(len,double=double,type=type)
;ARGS:
;    len:  long  length of window function
;KEYWORDS:
; double: if set the return a double array. the default is float
;   type: char   type of window:
;                'cos4'  cosine^4 window
;                'ecb'   extended cosine bell
;                'hsin'  half sine
;                'han'   hanning window
;                'ham'   hamming window
;                 The default is a hanning window
;DESCRIPTION:
;   Create a window function that can be used in fourier transform
;processing
;-
function windowfunc,len,type=type,double=double

    usedouble=keyword_set(double)
    if not keyword_set(type) then type='han'
    x= usedouble ? dindgen(len)*!dpi*2.D/len:$
                   findgen(len)*!pi *2./len
    p5 =usedouble ? .5d : .5
    one=usedouble ? 1d :  1.

    case type of 
        'han': return,p5*(one-cos(x))
        'ham': begin
                if usedouble then return, (.08D + .46D*(1d - cos(x)))
                return,.08+.46*(1.-cos(x))
               end
        'cos4': return,p5*((cos(x)-one)^2)
        'hsin': return,sin(x*p5)
        'ecb': begin
               if usedouble then begin
                y=.5d * (1.d - cos(x * 5.d))
               endif else begin
                y=.5*(1.-cos(x*5))
               endelse
               i1=len/10
               i2=len-i1
               y[i1:i2]=one
               return,y
               end
        else:message,'types are: cos4,han,ham,ecb,hsin'
    endcase
    return,x
end
