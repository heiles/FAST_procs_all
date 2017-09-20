;+
;NAME:
;fluxsrclist - return list of source names in flux file
;SYNTAX: fluxnames=fluxsrclist(print=print,freq=freq,size=size,bnames=bnames,$
;                              riseset=riseset,sortRise=sortRise,$
;                              srclist=srclist,all=all,exclvar=exclvar,$
;                              retall=fluxstr)
;ARGS:   none
;KEYWORDS:
;   print:       if set then print to stdout the source info for the sources
;                selected. This inclues the name, coefficients, fit rms, 
;                code and comments.
;   freq : float frequency in Mhz. If provided then evaluate the flux at
;                this frequency for every source returned. Return the
;                source names and flux in Janskies.
;   all  :       if set then return all available info on each source.
;                name (flux if Freq specified) CodeForSrc size/comments
;   size :       if set then include any size/comments for the sources
;  bnames:       if set only include sources that start with B.
; riseset:       if set then include rise,set times in list
; sortRise:      if set then sort by rise time.. default is name
;  srclist[]: string If supplied, then only supply info on the sources in
;                    this list that also meet the other criteria (bnames..).
;  exclVar:      if set then exclude variable sources (fit type = 2)
;  retall: {}    fluxstr. Return the entire flux structure for all of the
;                selected sources. 
;RETURNS:
;   A string array containing an entry for each source.
;   the first entry of every source is the name:
;       ret[0,*]= srcname
;   if freq keyword is present, the flux at this frequency will
;       follow the srcname
;       ret[1,*]= flux
;   if size keyword is set then any comments will follow the freq (or name
;   if no freq requested)
;       ret[2,*]= comments  or
;       ret[1,*]= comments  (if no freq keyword)
;
;DESCRPTION:
;   Return a list of the sources in the flux file (created by chris salter).
;If the /print keyword is supplied then the routine will also write the 
;source info to stdout.
;
;   By default the source name for all sources is returned. You can modify
;what is returned with the following keywords:
;
;   freq:  Evaluates and adds the flux for each source at freq(Mhz).
;   size:  adds the size/comments field in the returned data
;   all :  returns srcName (flux if frq supplied) code size/comments
; bnames:  Only return sources that start with B. The file has multiple
;          names for the same source (J,B, and 3C).
; riseset: Include rise/set times hhmmss.s in output
;srclist:  instead of searching the entire file, only look at the sources
;          in this list.
;
;EXAMPLES:
;1.   dat=fluxsrclist()       .. dat[] is a string array of all the sources
;     print,dat[0:3]
;
;     B0010+005 3C5 B0017+154 3C9
;
;2.   dat=fluxsrclist(/print) .. the file is also listed to std out:
;
;     prints:
;codes:1-good calibrator,2-lousy,3-flux.cat ??
;B0010+005 coef: 2.77 -0.82 0.00 rms: 9.00 code:1 ;3C5; Size~27"; Sp(80-5000)
;
;3.   dat=fluxsrclist(freq=1420).. dat[2,*] string array
;                                  dat[0,*] holds the source names.
;                                  dat[1,*] holds the flux (in Jy) for each src 
;                                           at 1420Mhz
;     print,dat[*,0:1]
;     3C132    3.21
;     3C138    9.14
;
;4.   dat=fluxsrclist(freq=1420,/size).. dat is a 2-d string array.
;                                dat[0,*] holds the source names.
;                                dat[1,*] holds the flux for each source
;                                dat[2,*] holds comments for this source
;     print,dat[*,0:1]
;     3C132    3.21 3C132 C27.6(756)
;     3C138    9.14 3C138 Fit to all S's
;
;5.   srclist=['B2223+21','3C138']
;     dat=fluxsrclist(freq=1420,/all,srclist=srclist).. dat[4,3] stringarray
;     print,dat
;     B1607+268    4.47   1 cut-off below 1 GHz
;     B1615+212    1.80   1  
;     B1622+238    2.63   1 3C336
;
;NOTE:
;   1. There are multiple names for the same source in the flux file (eg
;      B2314+038,3C459,J2316+040).
;   2. The code field is: 1 - good flux calibrator, 2-bad flux calibrator,
;                         3 - source from kuehr et al.Chris has not yet
;                             tried to fit this source.
;
;The flux file is located at aodefdir()/data/fluxsrc.dat. At AO, aodefdir() is
;/pkg/rsi/local/libao/phil/.
;SEE ALSO:
;   fluxsrc, fluxsrcload.
;-
function fluxsrclist,print=print,freq=freq,size=size,all=all,bnames=bnames,$
		   exclvar=exclvar,$
           riseset=riseset, sortRise=sortRise,srclist=srclist ,retall=fluxstr
    common fluxcom,fluxdata,fluxcominit

    if not keyword_set(fluxcominit) then fluxsrcload
    n=n_elements(fluxdata)
    ind=lindgen(n)
    usesrclist=0
    if  n_elements(srclist) gt 0 then begin
        usesrclist=1
        ind=(ind*0) - 1
        m=n_elements(srclist)
        for i=0,m-1 do begin
          ii=where(srclist[i] eq fluxdata.name,count)
          if (count eq 0) then begin
            print,srclist[i],' not in flux catalog' 
          endif else begin
            ind[ii[0]]=ii[0]
          endelse
        endfor
        ii=where(ind ge 0,count)
        if count eq 0 then begin
            print,'no sources found'
            return,''
        endif
        ind=ind[ii]
    endif
    if keyword_set(print) then begin 
        print,'codes:1-good calibrator,2-lousy,3-flux.cat ??'
        for i=0,n-1 do begin 
            useit=(not keyword_set(bnames)) or $
                (keyword_set(bnames) and (strmid(fluxdata[i].name,0,1) eq 'B'))
            if usesrclist then begin
                ii=where(i eq ind,count)
                if count eq 0 then useit= 0 
            endif
			if (keyword_set(exclVar) and (fluxdata[i].code eq 2)) then $
				useit=0 
            if useit then begin
			   if keyword_set(riseset) then begin
                lab=string(format=$
'(a9," coef:",3f7.2," rms:",f6.2," code:",i1,"rise/set:",i06,1x,i06," ",a)',$
            fluxdata[i].name,fluxdata[i].coef[0],$
            fluxdata[i].coef[1],fluxdata[i].coef[2], fluxdata[i].rms,$
            fluxdata[i].code,round([fluxdata[i].rise,fluxdata[i].set]),$
			fluxdata[i].notes)
		       endif else begin
                 lab=string(format=$
    '(a9," coef:",3f7.2," rms:",f6.2," code:",i1," ",a)',$
            fluxdata[i].name,fluxdata[i].coef[0],$
            fluxdata[i].coef[1],fluxdata[i].coef[2], fluxdata[i].rms,$
            fluxdata[i].code,fluxdata[i].notes)
               endelse
               print,lab
			endif
        endfor
    endif
    retfreq=(n_elements(freq) ne 0) ? 1 : 0
    retsize=(keyword_set(size)) ? 1 : 0
    retRiseSet=(keyword_set(riseset)) ? 2 : 0
    retGoodness=0
    if keyword_set(all) then begin
        retGoodness=1
        retsize=1
        retRiseSet=2
    endif
        
    n1=1+retfreq+retsize+retGoodness+retRiseSet
	indRise=-1
    if n1 gt 1 then begin
        k=0
        ret=strarr(n1,n)
        for i=0,n-1 do begin
            useit=(not keyword_set(bnames)) or $
        (keyword_set(bnames) and (strmid(fluxdata[i].name,0,1) eq 'B'))
			if (keyword_set(exclVar) and (fluxdata[i].code eq 2)) then $
				useit=0
            if usesrclist then begin
                ii=where(i eq ind,count)
                if count eq 0 then useit= 0 
            endif
            if useit then begin
              j=0
              ret[0,k]=fluxdata[i].name
              if retfreq then begin
                j=j+1
                ret[j,k]=string(format='(f7.2)',fluxsrc(fluxdata[i].name,freq))
              endif
              if retGoodness then begin
                j=j+1
                ret[j,k]=string(format='(i3)',fluxdata[i].code)
              endif
			  if retRiseSet ne 0 then begin
				 j=j+1
				 indRise=j
                 ret[j,k]=string(format='(i06)',round(fluxdata[i].rise))
				 j=j+1
                 ret[j,k]=string(format='(i06)',round(fluxdata[i].set))
			  endif
              if retsize then begin
                j=j+1
                ret[j,k]=fluxdata[i].notes 
              endif
              if arg_present(fluxstr) then begin
                  istr=(k eq 0)?i : [istr,i]
              endif
              k=k+1
            endif
        endfor
        ret=ret[*,0:k-1]
		if keyword_set(sortRise) then begin
			if indRise eq -1 then begin
			   print,"Need to include /riseset or /all to sort on rise time"
               ind=sort(ret[0,*])
			endif else begin
               ind=sort(ret[indRise,*])
			endelse
		endif else begin
               ind=sort(ret[0,*])
		endelse
        ret=ret[*,ind]
        if arg_present(fluxstr) then fluxstr=fluxdata[istr[ind]]
        return,ret
    endif
    if arg_present(fluxstr) then fluxstr=fluxdata[ind]
    return,fluxdata[ind].name
end
