;+
;pfplot - plot multiple sources after pfsrc processing
;SYNTAX: pfplot,srci,srco,x,y,xtitle,ytitle,title,notel,pol=pol,oplot=oplot,
;		 lnstyle=lnstyle,xp=xp,sbc=sbc,sep=sep,frq=frq
;ARGS: 
;		srci[nsrc]: {pfsrcinfo} . array describing each source
;		srco[npts]: {pfsrcout}.. hold all analyzed data for all sources
;	       x[npts]: x data to plot
;      y[pol,npts]: float y data (if sbc not defined)
;  y[pol,sbc,npts]: float y data (if sbc defined)
;	       xtitle : string - x axis title
;	       ytitle : string - y axis title
;	        title : string - plot title
;	       notel  : int    line number to start note on (1..30)
;KEYWORDS:
;		pol		  : int    1=A,2=B,3=both .. which pol to polot
;		oplot     : int    if set then overplot
;		lnstyle   : int    if set then linestyle same as color ind in srci
;		xp        : float  x position to strt note 0 to 1.
;		sbc       : int    0..3 index for sbc to use.
;					       > 3 --> plot all sbc
;						   If Key not present then assume data is stored
;						   as [pol,npts]
;		noteln    : int    line to start notes for,pola,polb and srcnames
;		oplot	  :        if set then overplot this call onto last plot made.
;		xp	      : float  0-1. xposition to start the note for polA, etc.
;		sep       :  if set then each sbc plot will be separate.
;		frq		  :  if set then plot freq on pola line
;		noflux    :  if set donot label the flux
;DESCRIPTION:
; 	Plot data by source. It uses srcinp,srcout, and the data to plot.
;SRCINP: 
;This was filled in by the user before calling pfsrc. It contains
;fluxes,npairs, srcnumber, and the symbol and color to use when 
;plotting this source.
;SRCOUT:
;	This has an entry for every point measured. It holds the tsys,gain
;info, but in this routine the only thing we use is the source
;number that allows us to index back into srcinp to find the
;srcinfo for plotting.
;
;PLOT OUTPUT:
;
; color    : srcinp[srnum].srccol
;		     if srccol == 0 then  polA=white,polb=green
; symbol   : srcinp[srnum].srcsym
; linestype: dots polA, dash polB
;			 if /lnstyle then linestyle uses srccol as index to symtbl
;SBC TO PLOT:
;  	sbc=0-3 plots just this sbc.
;      =4   overplots all sbc
;      not present --> the data is stored as y[2,npts] with no sbc dimension.
;A list of source names used will also be included with the fluxes for
;each source.
;-
pro pfplot,srci,srco,x,y,xtit,ytit,tit,notel,pol=pol,oplot=oplot,$
		lnstyle=lnstyle,xp=xp,sbc=sbcreq,frq=frq,sep=sep,noflux=noflux

;history:
; 26jul00: srcind ->srcsym, added srccol
;
   freql=strarr(4)
   for i=0,3 do begin
       a=srco[0].h.dop.freqbcrest+SRCO[0].h.dop.freqoffsets[i]
       freql[i]=string(format='(f5.0)',a)
   endfor

	
	doplot=not keyword_set(oplot)
	if n_params() lt 8 then notel=3
	if n_elements(pol) eq 0 then pol=3
	if n_elements(srcnum) eq 0 then srcnum=0
	if not keyword_set(lnstyle) then lnstyle=0
	if n_elements(xp) eq 0 then xp=.05
	if n_elements(sbcreq) eq 0 then sbcreq=-1
		
;  symbols:
;  1 2 3 4       5        6      7 
;  + * . diamond triangle square x
;
	sym=[1,2,4,5,6,7,1,2,4,5,6,7]
	maxsym=12
	maxcol=11
	ls1=1
	ls2=2
	numsrc=(size(srci))[1]
	polind=0
	if pol eq 2 then polind=1
	case 1 of 
	   sbcreq lt 0: begin	
					sbc1=0 
					sbc2=0
					end
	   (sbcreq ge 0) and (sbcreq le 3): begin	
					sbc1=sbcreq 
					sbc2=sbcreq
					end
		else: begin
				sbc1=0
				sbc2=(size(y))[2]-1
			  end
	endcase
; ---------------------------------------------------------------------------
;	loop over sbc
;
	for sbc=sbc1,sbc2 do begin
;
	for i=0,numsrc-1 do begin 
    	ind=where(srco.srcnum eq srci[i].srcnum) 
		symind= srci[i].srcsym mod maxsym
		colind= srci[i].srccol mod maxcol
		if (colind eq 0) then begin
			case pol of
				1: col1=1 
				2: col1=3
             else: begin
					col1=1
					col2=3
				   end
			endcase
		endif else begin
			col1=colind
			col2=colind
		endelse
;
;	if lnstyle set , make linestyle match color index
;
		if lnstyle ne 0 then begin
		   ls1=col1 
		   ls2=col2
		endif
;		print,"i:",i," symind:",symind
	    if sbcreq eq -1 then begin
    		if doplot then begin 
        		plot,x[ind] ,y[polind,ind],psym=-sym[symind],xtitle=xtit,$
				ytitle=ytit,title=tit,linestyle=ls1,/ystyle,/xstyle,color=col1
        	    doplot=0 
			endif else begin
               oplot,x[ind],y[polind,ind],psym=-sym[symind] ,linestyle=ls1,$
				 color=col1
			endelse
			if pol eq 3 then begin
           	oplot,x[ind] ,y[1,ind],psym=-sym[symind], linestyle=ls2,color=col2 
			endif
		endif else begin
    		if doplot then begin 
        		plot,x[ind] ,y[polind,sbc,ind],psym=-sym[symind],xtitle=xtit,$
				ytitle=ytit,title=tit,linestyle=ls1,/ystyle,/xstyle,color=col1
        		doplot=0 
    		endif else begin 
               oplot,x[ind],y[polind,sbc,ind],psym=-sym[symind] ,linestyle=ls1,$
				 color=col1
			endelse
			if pol eq 3 then begin
         		oplot,x[ind] ,y[1,sbc,ind],psym=-sym[symind], linestyle=ls2,$
						color=col2 
			endif
		endelse
	endfor
;
;	label each plot if separate or the last if overplotting
;
	if (keyword_set(sep) or (sbc eq sbc2) ) then begin
	 	ln=notel
		if lnstyle eq 0 then begin
			lab=' Freq: '
			if keyword_set(sep) then begin
				lab=lab + freql[sbc]
			endif else begin
				for j=sbc1,sbc2 do begin
					lab=lab + freql[j] +  ' '
				endfor
			endelse
			lab=lab + 'Mhz'
			if not keyword_set(frq) then lab=''
			if xp lt 1. then begin
			case pol of
			1: begin
				note,ln,  'dot   pol A ' + lab,xpos=xp
			   end		
			2: begin
				note,ln,  'dot   pol B' + lab,xpos=xp
			   end		
			3: begin
		 		note,ln,  'dot   pol A' + lab,xpos=xp
	  			note,ln+1,'dash  pol B',xpos=xp
		  	 	end
			endcase
			endif else begin
			case pol of
			1: begin
				note,ln,  'dot polA',xpos=xp
			   end		
			2: begin
				note,ln,  'dot polB',xpos=xp
			   end		
			3: begin
		 		note,ln,  'dot  polA',xpos=xp
	  			note,ln+1,'dash polB',xpos=xp
		  	 	end
			endcase
			note,ln,lab,xp=.5
			endelse
		endif
		for i=0,numsrc-1 do begin
			if keyword_set(noflux) then begin
				if (xp ge 1.0) then begin
				   line=string(format='(" ",a9)',srci[i].name)
				endif else begin
				   line=string(format='(" ",a9)',srci[i].name)
				endelse

			endif else begin
			  if  (sbcreq lt 4) or keyword_set(sep) then begin
				line=string(format='("  ",a10," flux:",F5.2)',$
					srci[i].name,srci[i].flux[sbc])
			  endif else begin
				line=string(format='("  ",a10," flux:")',srci[i].name)
				for k=0,(size(y))[2]-1 do begin
	  				line=line + string(format='(f5.2," ")',srci[i].flux[k])
				endfor
			  endelse
			endelse
			symind= srci[i].srcsym mod maxsym
			colind= srci[i].srccol mod maxcol
			note,ln+2+i,line,xpos=xp,sym=sym[symind],color=colind
		endfor
	endif
	if keyword_set(sep) then doplot=1
	endfor
	return
end
