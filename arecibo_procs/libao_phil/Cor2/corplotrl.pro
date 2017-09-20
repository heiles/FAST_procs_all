;+
;NAME:
;corplotrl - plot correlator data flagging recomb lines.
;
;SYNTAX   : corplotrl,b,recombI,m=pltmsk,pol=pol,extitle=extitle,rest=rest,$
;                    across=across,down=down,font=font,cs=cs,ncs=ncs
;
;ARGS     :
;        b: {corget} corget structure to plot
;recombI[]: {}       recombination lines to flag (see recombsearch()).
;KEYWORDS :
;        m: int      bitmask 0-15 to say which boards to plot
;                    1=brd 1  , 2=brd2   , 4=brd3, 8=brd4,
;                    3=brd12  , 5=brd13  , 7=brd123, 9=brd14..
;     pol : int      The polarization to plot (1 or 2). By default
;                    all polarizations are plotted.
;  extitle:string    add to title line
; across  : int      if supplied then the number of plots across the page
; down    : int      if supplied then the number of plots down the page
; font    : int      font to use (1=truetype)
; cs      : float    chars=cs value to use for plot
; ncs     : float    chars=ncs value to use for note labels &$
;DESCRPIPTION:
;   Plot correlator structure flagging the recombination line freqeuncies.
;The input data b should be a single corget structure. The recombination
;line information (recombI) is from the routine recombsearch(). 
;
;   The data is plotted in topocentric frequencies. The rest frequencies 
;of each recombination line will be doppler shifted by the doppler
;shift used for datataking (the doppler shift for the rf band center or the
;doppler shift for the center of each sub correlator). The routine
;uses color to differentiate the atoms. The linestyle (dots, dashes, etc..) 
;is separates the transitions (alpha,beta,..). Up to 8 atoms and 5
;transition steps can be displayed at once.
;
;   You can limit the subbcorrelators that are plotted with the m=pltmsk
; keyword. m is a bitmask where a 1 in a bit means plot the sbc. bit0(1)=sbc1,
;bit1(2)=sbc2, bit2(4)=sbc3,bit3(8)=sbc4. Any combination of these bits
;can be used.
;
;EXAMPLES:
;;   Flag any recombination lines between 1664 and 1680 for transitions 1 
;;thru 5. 
;   
;;   .. input correlator data into b
;;   .. look for recomb lines in this range
;
;   n=recombsearch(1664,1680,recombI,lineStepR=[1,5])
;   corplotrl,b,recombI
;
;; search for transitions 1 thru 10, plot the first 5 then the second five
;
;   n=recombsearch(1664,1680,recombI,lineStepR=[1,10])
;   ind1=where(recombi.lineStep le 5,count)
;   ind2=where(recombi.lineStep gt 5,count)
;;  steps 1.. 5 
;   corplotrl,b,recombI[ind1]
;;  steps 6..10
;   corplotrl,b,recombI[ind2]
;
;SEE ALSO: recombsearch(), recombfreq() in idl/gen
;
;
;NOTE:
;   The recombination line flagged will be offset from the measured value
;if the doppler shift used was different than that of the emission region.
;-
pro corplotrl,b,recombI,m=pltmsk,pol=pol,extitle=extitle,rest=rest,$
	across=across,down=down,cs=cs,ncs=ncs,font=font
;
; number of steps they have
;
    common colph,decomposedph,colph
    if (n_elements(pltmsk) eq 0) then plttmp=15 else plttmp=pltmsk
    numplts=0
    pltit=intarr(4)                 ; do we plot this boards o
    nsbc=n_tags(b[0])
    for i=0,nsbc-1 do begin
        pltit(i)= (plttmp and 1)
        numplts=numplts+pltit(i)
        plttmp=ishft(plttmp,-1)
    end
   if (not keyword_set(across)) then begin
        if (numplts gt 2) then across=2 else across=1
    endif
    if (not keyword_set(down)) then begin
        if (numplts gt 1) then down=2 else down=1
    endif
    if (not keyword_set(pol)) then pol=0
    if (n_elements(extitle) eq 0 ) then extitle=''
    !p.multi=[0,across,down]
;
    maxNumLnStep=5
    maxNumAtom  =8
    ind=uniq(recombI.linestep,sort(recombI.linestep))
    numLnStep=n_elements(ind)
    if numLnStep gt maxNumLnStep then begin
        ind=ind[0:maxNumLnStep-1]
        numLnStep=maxNumLnStep
    endif
    lnstepAr=recombI[ind].linestep
;
; number of atoms they have
; should sort by atomic number
;
    ind=uniq(recombI.atom,sort(recombI.atom))
    numAtom=n_elements(ind)
    if numAtom gt maxNumAtom then begin
        ind=ind[0:maxNumAtom-1]
        numAtom=maxNumAtom
    endif
    atomAr=recombI[ind].atom
;
    title=string(format=$
    '(a," scn:",i9)',string(b[0].b1.h.proc.srcname),b[0].b1.h.std.scannumber)
    title=title+extitle 
;
    colArAtom=(lindgen(numAtom) mod maxNumAtom) +  3
    lsar     =(lindgen(numLnStep) mod maxNumLnStep) + 1
    first=1
    for i=0,nsbc-1 do begin
        if pltit[i] eq 0 then goto,botloop
        isbc=i
        dop=b[0].(isbc).h.dop.factor
        if keyword_set(rest) then begin
            frq=corfrq(b[0].(isbc).h,/retrest)
        endif else begin
            frq=corfrq(b[0].(isbc).h)
        endelse
        y1=''
        y2=''
        if pol eq 0 then begin
            y1=b.(isbc).d[*,0]
            if b.(isbc).p[1] ne 0 then y2=b.(isbc).d[*,1]
        endif else begin
            case pol of
                1: y1=b.(isbc).d[*,0]
                2: y1=b.(isbc).d[*,1]
            endcase
        endelse
                    
        plot,frq,y1,chars=cs,font=font,$
            xtitle='freq [Mhz]',ytitle='deg K',$
            title=title
        if (y2[0] ne '') then oplot,frq,y2,color=colph[2]
    
        for istep=0,numLnStep-1 do begin
            ls=lsar[istep]
            step=lnStepAr[istep]
            for iatom=0,numAtom-1 do begin
                atom=atomAr[iatom]
                ind=where((recombI.atom eq atom) and (recombI.lineStep eq step),count)
                if count gt 0 then begin
                   flag,dop*recombI[ind].freq,linestyle=ls,$
                       col=colph[colArAtom[iatom]]
                endif
            endfor
        endfor
        if first then begin
            xp=.02
            scl=.6
            ln=2
            for j=0,numAtom-1 do note,ln+j*scl,atomAr[j],$
                 color=colph[colArAtom[j]],xp=xp,font=font,chars=ncs
            k=numAtom
            for j=0,numLnStep-1 do begin
                ls=lsar[j]
                lab=string(format='("   ",i1)',lnStepAr[j])
                note,ln+(k+j)*scl,lab,xp=xp,lnstyle=ls,chars=ncs,font=font
            endfor
            first=0
        endif
botloop:    
    endfor
    !p.multi=0
    return
end
