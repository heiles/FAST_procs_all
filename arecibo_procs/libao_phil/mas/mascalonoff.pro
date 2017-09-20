;+ 
;NAME:
;mascalonoff - compute cal scl factor from calon,caloff
;SYNTAX: istat=mascalonoff(bon,boff,calI,edgeFract=edgeFract,$
;                       usecalI=usecalI,mask=mask,cmpmask=cmpmask)
;ARGS  :
;   bon[n]:{}: mas struct hold cal on data. 
;              If n > 1 then each record is assumed to have the same header
;              setup (nchan,freqrange,npol,etc)
;              the cntsToK conversion factor will be averaged over all
;              of these records.
;  boff[n]:{}: mas struct holding cal off data. boff[n] must have n = to
;              bon[n]
; calI{} : struct   holding cal value info and conversion factors.
;                   Normally it is passed back to the caller. If useCalI
;                   is set then the calValue info is passed in via calI.
;                   The scale  factors calI.cntsToK are always passed back
;					in calI.
;KEYWORDS:
; edgeFract[2]: float fract of the bandpass edge to ignore when averaging.
;                      default: .06
;                      1 entry: use both for low,high freq side
;                      2 entery: [0] for lowFreq,[1] for high freq side
; useCalI:int 	    if true then use calI parameter for the cal value info.
;                   If you are doing more than one call with the same
;                   setup then this lets you skip the mascalval() call
;                   after the first call.
;mask[nchan]: int   mask to use for computing cals. !=0 --> use this channel.
;                   Should be the same order as the spectra eg 
;                   mask[0] corresponds the bon.d[0,xx]
;cmpmask    : int   if true then compute the mask useing calon/caloff
;                   It will also exclude echgeFract points from each
;                   side (def to 6%). If mask= keyword is also present
;                   then combine mask passed in with the bad channels we found
;                   from cmpmask.
;RETURNS:
; istat:  int   0 finished ok,  -1 error
;
; calI : {}       returns calInfo and conversion factors calI.cntsToK[2]
;
;** Structure <b7abad8>, 9 tags, length=64, data length=64, refs=1:
;   CALVAL    FLOAT  Array[2] ; averaged cals pola,b
;   exposure  float         0 ; integration time that cntstok corresponds to. 
;   NUMPOL    INT           2 ; number of pols 1 --> stokes I
;   CNTSTOK   FLOAT  Array[2] ; polA,b conversion cnts to Kelvins
;   NPNTS     LONG       4096 ; number points used for avg
;   FLIPPED   BYTE       1    ; 1 --> spectra is flipped
;   EDGEFRACT FLOAT  Array[2] ; edgeFract[0,1] fract to keep..spc order
;   USEMASK   BYTE      1     ; 1 --> used mask,0--> used edgefract
;   INDUSED   LONG  Array[4096]; indices into spc for channels used.
;                               same order as the spectra
;
;
;DESCRIPTION:
;   Compute the scale factors to convert from spectrometer counts to
; kelvins using calon,offs. The scale factors are returned in calI.cntsToK[2] 
; for polA,polb
;
;Examples:
;	istat=masgetfile('',bcalOn,filename=fnameOn)
;	istat=masgetfile('',bcalOff,filename=fnameOff)
;   istat=mascalonoff(bcalon,bcaloff,calI)
;
;   scale bcalOff to kelvins
;   TsysA=mean(bcalOff.d[*,0,*]*calI.cntsToK[0])
;   TsysB=mean(bcalOff.d[*,1,*]*calI.cntsToK[1])
;;
;;  If you want to convert individual channels to degK, you must remove
;;  the IF band pass:
;;
;   bpc=masmath(bcaloff,/avg)
;   bpc[*,0]=bpc[*,0]/mean(bpc[calI.freqInd[0]:calI.freqInd[1],0])
;   bcalOffK[*,0,*]= bcalOffK[*,0,*]/(
;
;NOTES:
;	Current restrictions:
;1. assumes calon,caloff have same integration time.
;2. fixed to work with stokes data
;3. need to check that polAdding works..
;
;-
;modhistory
;26jun09 - wrote
;
function mascalonoff,bon,boff,calI,useCalI=usecalI,$
					 edgeFract=edgeFract,mask=mask,cmpmask=cmpmask
    common colph,decomposedph,colph

;
;   
	if n_elements(cmpMask) eq 0 then cmpMask=0
	nrecs=n_elements(bon)
    ndumps=bon[0].ndump
	nspc=ndumps*nrecs
	nchan   =bon[0].nchan
	npol   =bon[0].npol
	double=size(bon[0].d[0],/type) eq 5
	one=(double)?1d:1.
;   ----------------------------------------------------------
;	do we need to correct for blanking?

	fftAccumDef=max(bon.st.fftaccum)
	ii=where(bon.st.fftaccum ne fftAccumDef,nblank)
	fftAccumAr=reform(bon.st.fftaccum,nspc)

;   calOn	

	if (~ bon[0].blankCorDone) and (nblank gt 0) then begin
		if npol eq 4 then begin
			don =(nspc gt 1)?reform(bon.d[*,0:1,*],nchan,2,nspc) $
				            :bon.d[*,0:1]
			npol=2
		endif else begin
			don =(nspc gt 1)?reform(bon.d,nchan,npol,nspc) :bon.d
		endelse
		for i=0,nblank-1 do don[*,*,ii[i]]*=(fftAccumDef*one)/fftAccumAr[ii[i]]
		don =(nspc gt 1)?total(don,3)/nspc :don 
	endif else begin
		if npol eq 4 then begin
			don =(nspc gt 1)?total(reform(bon.d[*,0:1,*],nchan,2,nspc),3)/nspc $
				:bon.d[*,0:1]
			npol=2
		endif else begin
			don =(nspc gt 1)?total(reform(bon.d,nchan,npol,nspc),3)/nspc $
				:bon.d
		endelse
	endelse

	fftAccumDef=max(boff.st.fftaccum)
	ii=where(boff.st.fftaccum ne fftAccumDef,nblank)
	fftAccumAr=reform(boff.st.fftaccum,nspc)
	if (~ boff[0].blankCorDone) and (nblank gt 0) then begin
        if npol eq 4 then begin
            doff =(nspc gt 1)?reform(boff.d[*,0:1,*],nchan,2,nspc) $
                            :boff.d[*,0:1]
            npol=2
        endif else begin
            doff =(nspc gt 1)?reform(boff.d,nchan,npol,nspc) :boff.d
        endelse
        for i=0,nblank-1 do doff[*,*,ii[i]]*=(fftAccumDef*one)/fftAccumAr[ii[i]]
        doff =(nspc gt 1)?total(doff,3)/nspc :doff
    endif else begin
        if npol eq 4 then begin
            doff =(nspc gt 1)?total(reform(boff.d[*,0:1,*],nchan,2,nspc),3)/nspc $
                :boff.d[*,0:1]
            npol=2
        endif else begin
            doff =(nspc gt 1)?total(reform(boff.d,nchan,npol,nspc),3)/nspc $
                :boff.d
        endelse
    endelse
	
	if n_elements(mask) gt 0 then maskl=mask
	if   cmpMask ne 0   then begin
		tosmo=nchan*.03
		r=total(don,2)/total(doff,2)
		r=r/smooth(r,tosmo)
		r[0:tosmo]=0.
		r[nchan-tosmo:*]=0.
		x=(double)?dindgen(nchan)/nchan:findgen(nchan)/nchan
		case n_elements(edgefract) of
			1: edgefractL=[edgeFract,edgeFract]*one
			2: edgeFractL=edgeFract *one
		 else: edgefractL=[.06,.06]*one
		endcase
		nn=edgeFractL*nchan
		i1=(nn[0] gt 0)?nn[0]-1:0
		i2=(nn[0] gt 0)?nchan-nn[1]:nchan-1
		mm=i2-i1 + 1
		ii=lindgen(mm)+i1
		deg=1
		nsig=3
		coef=robfit_poly(x[ii],r[ii],deg,nsig=nsig,bindx=bindx,nbad=nbad)
	    if n_elements(maskl) eq 0 then maskl=intarr(nchan)+1 
		if nbad gt 0 then  maskl(bindx+i1)=0
;
;       0 out edgefract on the edges.
;
		maskL[0:i1]=0
		maskL[i2:*]=0
	endif
		
	if (~ keyword_set(usecalI) ) then  begin
    	istat=mascalval(boff[0].h,calI,edgeFract=edgeFract,mask=maskL)
		if istat lt 0 then begin
			print,"Error reading calValues:"
			return,-1
		endif
	endif
	calDif=don-doff
   	calI.cntsToK[0]=calI.calval[0]/(total(caldif[calI.indused,0],1)/calI.npnts)
	if npol gt 1 then begin
   		calI.cntsToK[1]=calI.calval[1]/$
				(total(caldif[calI.indused,1],1)/calI.npnts)
	endif
	calI.exposure=bon[0].h.exposure
	return,0
end
