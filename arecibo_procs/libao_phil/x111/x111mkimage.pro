;
function x111mkimage,yymmdd1,yymmdd2,rcvNum,frqStart,nbands,img,xfrq,$
		xtit=xtit,ytit=ytit,tit=tit,border=border,$
		xmaxpix=xmaxpix,ymaxpix=ymaxpix,verb=verb,cs=cs,$
		deg=deg,fsin=fsin,clip=clip
;
; 0 error, 1 ok
	retstat=0
	if n_elements(xtit) eq 0 then xtit='Freq [MHz]'
	if n_elements(ytit) eq 0 then ytit='1 second records (in groups of 60)'
	if n_elements(border) eq 0 then border=90
	if n_elements(cs) eq 0 then cs=1.5
	if n_elements(verb) eq 0 then verb=-1
;   max number channels in image. should be less then pixels on screen
	if n_elements(xmaxpix) eq 0 then xmaxpix=1900
	if n_elements(ymaxpix) eq 0 then ymaxpix=900
	if n_elements(deg) eq 0 then deg=1
	if n_elements(fsin) eq 0 then fsin=20
 	if n_elements(clip) eq 0 then clip=.2

	ndel=3
	edg=.02
	; for title
	ln=1.5

	F0lbw=1111.5
	F0xb=7961.5
	F0cb=3961.5 
	F0cbh=5911.5
	F0sbh=3000. 
	F0sbw=1761.5
	F0800=715
	bandStp=23
	case rcvNum of
		1:begin 
		  maxBands=1
		  frq0=327
	      nbandsl=1 
		 end
		2:begin 
		  maxBands=1
		  frq0=430
	      nbandsl=1 
		 end
		3:begin
		    maxBands=4
			far=findgen(maxBands)*bandStp + F0800
			ii=min(abs(frqStart - far),iuse)
			frq0=far[iuse]
			nbandsl=min([nbands,(maxBands-iuse)])
		  end
		5:begin
			maxBands=32
			far=findgen(maxBands)*bandStp + F0lbw
			ii=min(abs(frqStart - far),iuse)
			frq0=far[iuse]
			nbandsl=([nbands,(maxBands-iuse)])
		  end
		7:begin
;           not contiguous.. probabaly trouble
			maxBands=15*4
			far=findgen(maxBands)*bandStp + F0sbw
			ii=min(abs(frqStart - far),iuse)
			frq0=far[iuse]
			nbandsl=min([nbands,(maxBands-iuse)])
		  end
        8:begin
            maxBands=11*4
            far=findgen(maxBands)*bandStp + F0sbh
            ii=min(abs(frqStart - far),iuse)
            frq0=far[iuse]
            nbandsl=min([nbands,(maxBands-iuse)])
          end
        9:begin
            maxBands=24*4
            far=findgen(maxBands)*bandStp + F0cb
            ii=min(abs(frqStart - far),iuse)
            frq0=far[iuse]
            nbandsl=min([nbands,(maxBands-iuse)])
          end
        10:begin
            maxBands=25*4
            far=findgen(maxBands)*bandStp + F0cbh
            ii=min(abs(frqStart - far),iuse)
            frq0=far[iuse]
            nbandsl=min([nbands,(maxBands-iuse)])
          end
	   11:begin
            maxBands=22*4
            far=findgen(maxBands)*bandStp + F0xb 
            ii=min(abs(frqStart - far),iuse)
            frq0=far[iuse]
            nbandsl=min([nbands,(maxBands-iuse)])
          end
	   12:begin
            maxBands=1*4
            far=findgen(maxBands)*bandStp + F0sbn
            ii=min(abs(frqStart - far),iuse)
            frq0=far[iuse]
            nbandsl=min([nbands,(maxBands-iuse)])
		 end 
		else: begin
				print,"Illegal rcvnumber. valid are:"
				print," 1-327,2-430gr,3-800Mhz,5-lbw,7-sbw,9-cb,10-cbh,11-xb,12-sbn"
				return,0
		      end
	endcase

	cfrInp=findgen(nbands)*bandStp + frq0
	pdat=ptrarr(nbands)
;
	minSets=1e6
	for iband=0,nbands-1 do begin
		n=x111inp(yymmdd1,yymmdd2,cfrInp(iband),bret,rcv=rcvnum,/han,verb=verb)
		if n eq 0 then begin
			print,"No data rcv:",rcvnum,"freq:",cfrInp(iband)," dates:",yymmdd1,yymmdd2
			goto,done
		endif
		if verb then begin
			hor
			ver
			corplot,bret.bdat[0]
		endif
		nsets=n_elements(bret.bdat[0,*])
		minSets=minSets<nsets
		for i=0,nsets-1 do begin &$
			bmed=cormedian(bret.bdat[*,i]) &$
			istat=corblauto(bmed,bfit,ndel=ndel,deg=deg,fsin=fsin,verb=verb,$
				edge=edg) &$
			bret.bdat[*,i]=cormath(bret.bdat[*,i],bfit,/div) &$
		endfor
		pdat[iband]=ptr_new(bret)
	endfor
;
; make sure same number of sets to use
;
	setsToUse=minSets
;
	istat=x111interpimgs(pdat,img,xfrq,SetsToUse)
	nx=n_elements(xfrq)
	ny=n_elements(img[0,*])
	zx=long(nx/xmaxpix)
	if nx/zx gt xmaxpix then zx++
	zy=long(ny/ymaxpix)
	if ny/zy gt ymaxpix then zy++
	zy=-zy
	zx=-zx
	nsig=3
	!p.multi=0 
	xr=[min(xfrq),max(xfrq)]
	imgdisp,((img-1.)> (-clip[0]))< (clip[0]),zx=zx,zy=zy,nsig=nsig,xr=xr,$
		xtitle=xtit,ytitle=ytit,mytitle='',chars=cs,border=border
	note,ln,tit,chars=cs
	retstat=1
	
done:
	if ptr_valid(pdat[0]) then ptr_free,pdat
	return,retstat
end
