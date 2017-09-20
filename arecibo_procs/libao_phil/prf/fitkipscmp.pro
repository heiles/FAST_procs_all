; functions:
; totKips= fk_temptdpos(temp,avgTdPos)
; totKips= fk_tempHght(temp,platformHght)
; kips1td= fk_tdkips(temp,tdpos,az,za)
;
;------------------------------------------------------------------------------
;+
; fk_temptdposfunc - function to kipTot to avg tdPos and temp
;-
function fk_temptdposfunc,x,m
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
;
; function to fit total tension to temperature and average tdpos
;         
	i=long(x+.5)
	avgtdpos=double((fitkipsdat[i].pos[0]+fitkipsdat[i].pos[1]+$
				 	 fitkipsdat[i].pos[2])/3.D)
	return,[ [1.D],[double(fitkipsdat[i].temp)],[avgtdpos]]
end
;------------------------------------------------------------------------------
;+
; fk_temptdpos - fit total kips to temp, avg tdpos
;-
pro fk_temptdpos,kipsd,c0,ctemp,ctdpos,yfit=yfit
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
	forward_function fk_temptdposfunc
;
; function to fit total tension to temperature and average td height
;         
	fitkipsdat=kipsd
	npts=(size(fitkipsdat))[1]
	x=findgen(npts)
    numparms=3
    A=SVdfit(x,fitkipsdat.kipst,numparms,function_name='fk_temptdposfunc',$
			/double,singular=sng,yfit=yfit)
;
    if  sng ne 0 then  print,$
			"svdfit returned singularity fitting kips vs temp,tdpos"
	c0   =a[0]
	ctemp=a[1]
	ctdpos=a[2]
	return
end
;------------------------------------------------------------------------------
;+
; fk_temphghtfunc - function to kipTot to platform height and temp
;-
function fk_temphghtfunc,x,m
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
;
; function to fit total tension to temperature and platform height
;         
	i=long(x+.5)
	return,[ [1.D],[double(fitkipsdat[i].temp-fktempAvg)],$
				[double(fitkipsdat[i].hght-fkhghtAvg)]]
end
;------------------------------------------------------------------------------
;+
;NAME:
; fk_temphght - fit totalkips=f(temp,plHght)
;SYNTAX: fk_temphght,kipsd,c0,ctemp,chght,yfit=yfit,tempavg=tempavg,$
;					hghtavg=hghtavg
;  ARGS:
;	kipsd[]: {tdlr} data to fit
;RETURNS:
;	c0	: double constant term
;  ctemp: double linear temp term
;  chght: double linear hght term
;   yfit: double input fit evaluated at the input points.
;DESCRIPTION:
;	fit totKips=c0+ctemp*TempDF +chght*plHgtFt
;	for the data isn kipsd
; note: 2000 data fit with hghtavg=1256, temp=0
;-
pro fk_temphght,kipsd,c0,ctemp,chght,yfit=yfit,tempavg=tempavg,hghtavg=hghtavg
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
	forward_function fk_temphghtfunc
;
; function to fit total tension to temperature and platform height
;         
	fitkipsdat=kipsd
	npts=(size(kipsd))[1]
	x=findgen(npts)
    numparms=3
	if n_elements(tempavg) eq 0 then tempavg=74.D
	if n_elements(hghtavg) eq 0 then hghtAvg=1256.35d
	fktempAvg=tempAvg
	fkhghtAvg =hghtAvg
    A=SVdfit(x,fitkipsdat.kipst,numparms,function_name='fk_temphghtfunc',$
			/double,singular=sng,yfit=yfit)
;
    if  sng ne 0 then  print,$
			"svdfit returned singularity fitting kips vs temp,height"
	c0   =a[0]
	ctemp=a[1]
	chght=a[2]
	return
end
;------------------------------------------------------------------------------
;+
; fk_tdkipsfunc - function to kips 1 td
;-
function fk_tdkipsfunc,x,m
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
;
; function to fit tension 1 td
; A0          +  A1*temp + 
; A2*tdPos[0] +  A3*tdPos[1]  +  A4*tdPos[2] + 
; A5*cos(az-tdAzimuth)*sin(za)+  A6*cos(az-tdAzimuth)*cos(za)
;
    i=long(x+.5)
	case tdind  of
	0:   azRd=double((fitkipsdat[i].az - 2.87))*!dtor
	1:   azRd=double((fitkipsdat[i].az - 122.87))*!dtor
	2: 	 azRd=double((fitkipsdat[i].az - 242.87))*!dtor
   else: message,"fk_tdkipsfunc call with tdindex bad"
	endcase
	zaRd=double(fitkipsdat[i].gr)*!dtor
    return,[ [1.D],[double(fitkipsdat[i].temp)],$
	[double(fitkipsdat[i].pos[0])],[double(fitkipsdat[i].pos[1])],$
	[double(fitkipsdat[i].pos[2])],$
	[cos(azRd)*sin(zaRd)], [cos(azrd)*cos(zaRd)]]
end
;------------------------------------------------------------------------------
;+
; fk_tdkipseval - evaluate fitting function for td
;-
function fk_tdkipseval,d,coef,tdInd
;
; function to fit tension 1 td
; A0          +  A1*temp +
; A2*tdPos[0] +  A3*tdPos[1]  +  A4*tdPos[2] +
; A5*cos(az-tdAzimuth)*sin(za)+  A6*cos(az-tdAzimuth)*cos(za)
;
    case tdind  of
    0:   azRd=double((d.az - 2.87))*!dtor
    1:   azRd=double((d.az - 122.87))*!dtor
    2:   azRd=double((d.az - 242.87))*!dtor
   else: message,"fk_tdkipseval tdInd : 0..2"
    endcase
	
    zaRd=double(d.gr)*!dtor
    return,coef[0]          + $
           coef[1]*d.temp   + $
           coef[2]*d.pos[0] + $
           coef[3]*d.pos[1] + $
           coef[4]*d.pos[2] + $
           coef[5]*cos(azRd)*sin(zaRd) + $
           coef[6]*cos(azRd)*cos(zaRd)
end
;------------------------------------------------------------------------------
;+
; fk_tdkips - fit tension 1 td to 
;-
pro fk_tdkips,kipsd,tdindex,tdcoef,yfit
	common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
    forward_function fk_tdkipsfunc
;
; function to fit td tension 1 td
;
	coef=dblarr(7)
	tdind=tdindex
    npts=(size(kipsd))[1]
    x=findgen(npts)
    numparms=7
	fitkipsdat=kipsd
	kips=fitkipsdat.kips[0,tdindex] + fitkipsdat.kips[1,tdindex]
    tdcoef=SVdfit(x,kips,numparms,function_name='fk_tdkipsfunc',$
            /double,singular=sng,yfit=yfit)
;
    if  sng ne 0 then  print,$
            "svdfit returned singularity fitting kips vs temp,height"
    return
end
;------------------------------------------------------------------------------
;+
; fk_tdkipsallfunc - function to kips 1 td
;-
function fk_tdkipsallfunc,x,m
    common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
;
; function to fit tension 1 td
; A0          +  A1*(platHght-1256.22)*12. + 
; A2*tdPos[0] +  A3*tdPos[1]  +  A4*tdPos[2] + 
; A5*cos(az-tdAzimuth)*sin(gr)+  A6*cos(az-tdAzimuth)*cos(gr)
; A7*cos(az-tdAzimuth)*sin(ch)+  A8*cos(az-tdAzimuth)*cos(ch)
;
    i=long(x+.5)
    case tdind  of
    0:   azRd=double((fitkipsdat[i].az - 2.87))*!dtor
    1:   azRd=double((fitkipsdat[i].az - 122.87))*!dtor
    2:   azRd=double((fitkipsdat[i].az - 242.87))*!dtor
   else: message,"fk_tdkipsfunc call with tdindex bad"
    endcase
    grRd=double(fitkipsdat[i].gr)*!dtor
    chRd=double(fitkipsdat[i].ch)*!dtor
    return,[ [1.D], [double(fitkipsdat[i].hght-1256.22)*12.],$
    [double(fitkipsdat[i].pos[0])],[double(fitkipsdat[i].pos[1])],$
    [double(fitkipsdat[i].pos[2])],$
    [cos(azRd)*sin(grRd)], [cos(azrd)*cos(grRd)],$
    [cos(azRd)*sin(chRd)], [cos(azrd)*cos(chRd)]]
end
;------------------------------------------------------------------------------
;+
; fk_tdkipsall - fit tension all td to,az,gr,ch,temp, 
;-
pro fk_tdkipsall,kipsd,tdindex,tdcoef,yfit,$
		sigma=sigma,variance=variance ,covar=covar
    common fitkips,fitkipsdat,tdind,fktempAvg,fkhghtAvg
    forward_function fk_tdkipsfunc
;
; function to fit td tension 1 td
;
    coef=dblarr(9)
    tdind=tdindex
    npts=(size(kipsd))[1]
    x=findgen(npts)
    numparms=9
    fitkipsdat=kipsd
    kips=reform(fitkipsdat.kips[0,tdindex] + fitkipsdat.kips[1,tdindex])
    tdcoef=SVdfit(x,kips,numparms,function_name='fk_tdkipsallfunc',$
            /double,singular=sng,yfit=yfit,variance=variance,covar=covar,$
			sigma=sigma)
;
    if  sng ne 0 then  print,$
            "svdfit returned singularity fitting kips vs temp,height"
    return
end
;------------------------------------------------------------------------------
;+
; fk_tdkipsalleval - evaluate fitting function for td all
;-
function fk_tdkipsalleval,d,coefAll
;
; function to fit tension all td
; A0          +  A1*temp +
; A2*tdPos[0] +  A3*tdPos[1]  +  A4*tdPos[2] +
; A5*cos(az-tdAzimuth)*sin(gr)+  A6*cos(az-tdAzimuth)*cos(gr)
; A7*cos(az-tdAzimuth)*sin(ch)+  A8*cos(az-tdAzimuth)*cos(ch)
; a9*(pltght-1256.22)
;
	n=n_elements(d)
	kips=fltarr(n,3)
	coefL=reform(coefAll,10,3)
	azOff=[2.87,122.87,242.87]
    grRd=double(d.gr)*!dtor
    chRd=double(d.ch)*!dtor
	for i=0,2 do  begin
		azRd=(d.az-azOff[i])*!dtor
        kips[*,i]=coefL[0,i]  + $
		   coef[1,i]*(d.hght-1256.22)*12. +$
           coef[2,i]*d.pos[0] + $
           coef[3,i]*d.pos[1] + $
           coef[4,i]*d.pos[2] + $
           coef[5,i]*cos(azRd)*sin(grRd) + $
           coef[6,i]*cos(azRd)*cos(grRd) + $
           coef[7,i]*cos(azRd)*sin(chRd) + $
           coef[8,i]*cos(azRd)*cos(chRd)
	endfor
	return,kips
end
