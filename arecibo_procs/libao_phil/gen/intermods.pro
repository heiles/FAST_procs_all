;+
;NAME:
;intermods - compute intermods between 2 freq.
;SYNTAX: n=intermods(f1,f2,minfreq,maxfreq,maxorder,outI,nf1,nf2,
;					neg=neg,all=all)G
;ARGS:
;f1: 	float	Mhz. First frequency to use
;f2:    float	Mhz. 2nd freq to use.
;minFreq: float Mhz. Minimum intermod freq to keep
;maxFreq: float Mhz. Maximum intermod freq to keep
;maxOrder: int  maximum intermod to compute on each freq.
;               eg 5 --> up to f1^5, f2^5
;KEYWORDS:
;	neg:		If set then include intemods < 0.
;   all:        if set then include all intermods found. 
;               by default only unique intermods are retured even if there
;               different orders that generate them.
;RETURNS:
;	n   :   int	number of intermods we found with requested range
;outI[n]:   float  the intermod value for each found
;nf1[n] :   int    the order for f1 for the nth intermod
;nf2[n] :   int    the order for f2 for the nth intermod
;
;DESCPRIPTION:
;	Compute intermods between the two frequencies input (f1,f2). If only
;one frequency is entered (f1) then just compute the harmonics of this
;frequency.
;	The maxorder keyword tells how high an order to use. All of the
;intermods of the various harmonics of f1,f2 (up to maxorder) are computed.
;Those they lay within the range minFreq,maxFreq are kept.
;
;	The intermod differences are returned in outI. The order for each intermod
;is returned in the array nf1 and nf2.
;-

function intermods,f1,f2,minfreq,maxfreq,maxorder,out,nf1,nf2,neg=neg,all=all
;
    maxcount=10000L
    out =fltarr(maxcount)
    nf1=fltarr(maxcount)
    nf2=fltarr(maxcount)
    f1l=(findgen(maxorder)+1)*f1
    f2l=(findgen(maxorder)+1)*f2
    last=0
;
; if just one freq, print out the harmonics and return
;
    if f2 le 0 then begin
        ind=where((f1l ge minfreq) and (f1l le maxfreq),count)
        if count gt 0 then begin
            last=count
            out[0:count-1]=f1l[ind]
            nf1=ind+1
            nf2=ind+1
        endif
        goto,done
    endif
;
; loop through to max order
;   take f1 - shift f2  +/-
;
    for i=0,maxorder-1 do begin
        if (keyword_set(neg)) then begin
		  lim=max(abs([minfreq,maxfreq])+1.)
          if i gt 0 then begin
			
            a=(f1l-shift(f2l,i))
            b=(f1l+shift(f2l,i))
            c=(f2l-shift(f1l,i))
            d=(f2l+shift(f1l,i))
            a[0:i-1]=-lim
            b[0:i-1]=-lim
            c[0:i-1]=-lim
            d[0:i-1]=-lim
          endif else begin
            a=(f1l-f2l)
            b=(f1l+f2l)
            c=(f1l-f2l)
            d=(f1l+f2l)
          endelse
        endif else begin
          if i gt 0 then begin
            a=abs(f1l-shift(f2l,i))
            b=abs(f1l+shift(f2l,i))
            c=abs(f2l-shift(f1l,i))
            d=abs(f2l+shift(f1l,i))
            a[0:i-1]=minfreq-1
            b[0:i-1]=minfreq-1
            c[0:i-1]=minfreq-1
            d[0:i-1]=minfreq-1
          endif else begin
            a=abs(f1l-f2l)
            b=abs(f1l+f2l)
            c=abs(f1l-f2l)
            d=abs(f1l+f2l)
          endelse
        endelse
;       print,a
        inda=where((a ge minfreq) and (a le maxfreq),counta)
        indb=where((b ge minfreq) and (b le maxfreq),countb)
        indc=where((c ge minfreq) and (c le maxfreq),countc)
        indd=where((d ge minfreq) and (d le maxfreq),countd)
        if counta gt 0 then begin
            out[last:last+counta-1]  = a[inda]
            nf1[last:last+counta-1]  =   inda + 1 
            nf2[last:last+counta-1]  =   (inda + 1)-i
            if ((last + counta) ge maxcount) then goto,done
            last=last+counta
        endif
        if countb gt 0 then begin
            out[last:last+countb-1]  =   b[indb]
            nf1[last:last+countb-1]  =   indb + 1 
            nf2[last:last+countb-1]  =   (indb + 1)-i
            if ((last + countb) ge maxcount) then goto,done
            last=last+countb
        endif
        if countc gt 0 then begin
            out[last:last+countc-1]  =   c[indc]
            nf1[last:last+countc-1]  =   (indc + 1 )-i ; we took f2-f1 so switch
            nf2[last:last+countc-1]  =   (indc + 1 )
            if ((last + countc) ge maxcount) then goto,done
            last=last+countc
        endif
        if countd gt 0 then begin
            out[last:last+countd-1]  =   d[indd]
            nf1[last:last+countd-1]  =   (indd + 1 )-i 
            nf2[last:last+countd-1]  =   (indd + 1 )
            if ((last + countd) ge maxcount) then goto,done
            last=last+countd
        endif
    endfor
done:
    if last gt 0 then begin
        out =out[0:last-1]
        nf1=nf1[0:last-1]
        nf2=nf2[0:last-1]
;
;	don't keep identical harmonics in each order
;
		for i=0,last-1 do begin
			ii=where((nf1 eq nf1[i]) and (nf2 eq nf2[i]) and $
					 (nf1[i] ne 0),cnt)
			if cnt gt 1 then begin
				nf1[ii[1:*]]=0
				nf2[ii[1:*]]=0
			endif
		endfor
		ii=where(nf1 ne 0,cnt)
		if cnt lt last then begin
			nf1=nf1[ii]
			nf2=nf2[ii]
			out=out[ii]
	        last=cnt
	    endif
;
; get rid of duplicates
;
        if not keyword_set(all) then begin
            outu=out[uniq(out,sort(out))]
            nfrqu=n_elements(outu)
            nf1u=lonarr(nfrqu)
            nf2u=lonarr(nfrqu)
            for i=0,nfrqu-1 do begin
                ind=where(out eq outu[i])
                nf1u[i]=nf1[ind[0]]
                nf2u[i]=nf2[ind[0]]
            endfor
            out=outu
            nf1=nf1u
            nf2=nf2u
            last=nfrqu
        endif
    endif else begin
        out=''
    endelse

    return,last
end
