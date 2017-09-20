;+
;calibtsyspl - plot tsys vs za for a receiver
;SYNTAX: npnts=calibtsyspl(rfnum,hsum,cals,title=title,col=col,syms=syms,$
;			     	 	   noteln=noteln,xp=xp,verreq=verreq,horreq=horreq
;ARGS:
;
;RETURNS:
;		number of entries found..
;DESCRIPTION:
;	Plot system temperature for all on/offs of a particular receiver for a
;calibration run using caliball. To generate the input data:
;1. nhdrs=pfinphdrm(lun,nrecs,hsum).. inputs hdr summaries each scan
;2. hcals=pfcalonoff(hsum,cals)	   .. finds/computes  cals/tsys
;3. then call this routine         .. extracts those of interest 
;
;-
function calibtsyspl,rfnum,hsum,cals,title=title,col=col,syms=syms,$
		noteln=noteln,xp=xp,verreq=verreq,horreq=horreq
;
	ver=fltarr(2,16)
	ver[0,*]=0
	ver[1,*]=100
	ver[*,2-1]=[40,70]			;# 430
    ver[*,3-1]=[70,160]         ;# 610
    ver[*,5-1]=[20,60]          ;# lbw
    ver[*,6-1]=[20,40]          ;# lbn
    ver[*,7-1]=[50,80]          ;# sbw
    ver[*,9-1]=[20,40]          ;# cband
    ver[*,12-1]=[20,40]          ;# sbn
	lnstyle=[0,1,2,4]

	if not keyword_set(title) then title='Calibration Tsys'
 	if not keyword_set(col)   then col =[1,2,3,5]
 	if not keyword_set(syms)  then syms=[-1,-2]
 	if not keyword_set(noteln) then noteln=3
 	if not keyword_set(xp)     then xp=.05
 	if not keyword_set(over)   then over=0

	pfcalquery,hsum,cals,'rfnum',rfnumAr
	pfcalquery,hsum,cals,'za',za
	pfcalquery,hsum,cals,'frq',frq
	npts=n_elements(rfNumAr)
	if npts eq 0 then return,0
	ind=where(rfnumAr eq rfnum,count)
	if count eq 0 then return,0
    nbrds=max(cals[ind].bind,maxind) + 1 
;
;	get the n frequencies.. just go backwords from the max board..
;
	freqL=fltarr(4)
	for i=0,nbrds-1 do begin
		indb=where((cals.bind eq i) and (rfnumAr eq rfnum))
		freqL[i]=frq[indb[0]]
		print,'i:',i,' freqL:',freqL[i],' ind:',indb[0]
	endfor
    titleloc=string(format='(a," ",a)',title,rfname(rfnum))
;
;	vertical scale .. used default unless /ver set or
;
	if ( (not over) and (not keyword_set(verreq))) then begin
	        ver,ver[0,rfnum-1],ver[1,rfnum-1] 
	endif
	if ( not over and (not keyword_set(horreq))) then begin
	        hor,0,20
	endif
	lnloc=noteln+2
    for j=0,nbrds-1 do begin 
        indsbc=where((cals[ind].bind eq j) and (cals[ind].pol eq 1))
		zal=za[ind[indsbc]]
		tsys=cals[ind[indsbc]].tsysoff
		indsort=sort(zal)
        if (j eq 0) and (over eq 0) then begin 
            plot,zal[indsort],tsys[indsort],color=col[j],$
            psym=syms[0],/xstyle,/ystyle,title=titleloc,linestyle=lnstyle[j]
        endif else begin 
            oplot,zal[indsort],tsys[indsort],color=col[j],$
            psym=syms[0],linestyle=lnstyle[j]
        endelse 
        indsbc=where((cals[ind].bind eq j) and (cals[ind].pol eq 2)) &$
		zal=za[ind[indsbc]]
		tsys=cals[ind[indsbc]].tsysoff
		indsort=sort(zal)
        oplot,zal[indsort],tsys[indsort],color=col[j],$
            psym=syms[1],linestyle=lnstyle[j] &$
        note,lnloc+j,string(format='(" freq ",f6.1)',freql[j]),xp=xp,$
                col=col[j],lnstyle=lnstyle[j] &$
    endfor
	note,noteln  ,'  pol A',sym=syms[0],xp=xp
	note,noteln+1,'  pol B',sym=syms[1],xp=xp
	return,npts/2
end
