;+
;NAME: 
;rfimkhist - make rfi histograms
;SYNTAX: rfimkhist,nm,yymm,sigma=sigma,badfr=badfr,prefnm=prefnm,$
;               outdir=outdir,mklist=mklist,frange=frange,$
;               frqstep=frqstep,verbose=verbose, wait=wait,han=han,$
;				alfaBadBms=alfaBadBms
;ARGS:
;   nm    : string .. receiver name to process
;   yymm[]: int array holding mon,year to process
;
;KEYWORDS:
;   sigma : float number of sigmas to clip at.
;   badfr : float  fraction before we call it bad spectra
; frqstep : float  freq step (def .1 Mhz)
; frange[2]: float  min max freq (mhz) for histogram. default is from table
;		           below.
; verbose :        if set then output clipping info
; wait    :        if set then wait after each spectra for keyboard input
; outdir  :string  for inplistfiles and output histogram files.
; mklist  :        if set then make the input filelists.
; prefnm  :string  prepend to each output file name
; han     :        hanning smoothing was used in rms computation.def=yes
;                  if not, then set han=0
;alfaBadBms[2,8]: int bad beams for alfa.. [pol, bm]
;                    8 beams since last is duplicated in wapps.
;                    putting a 1 in a location will ignore this
;                    pol,beam in the histogram. use for bad beams..
;-
pro  rfimkhist,nm,yymm,f1,f2,sigma=sigma,badfr=badfr,prefnm=prefnm,$
              outdir=outdir,mklist=mklist,frqstep=frqstep,verbose=verbose,$
                wait=wait,han=han,frange=frange,alfaBadBms=alfaBadBms
                
    namar =['327','430','800','lb','sb'    ,'sbh','cb','cbh','xb','alfa']
    f1list=[300   ,400  ,700  ,1100 ,1800  ,3000 , 4000,6000,8000  ,1220]
    f2list=[350   ,450  ,800  ,1800 ,3100  ,4000 , 6000,8000,10000 ,1520]
    fstep =[    .1,   .1,   .1,   .1,    .1,  .1,.1,.1,.1,.1]
    rcvlist=[[1,0],[2,0],[3,0],[5,0],[7,12],[8,0],[9,0],[10,0],[11,0],[17,0]]
;
    ind=where(nm eq namar,count)
    if count le 0 then begin 
        line='valid names are:' + namar
        message,line
    endif
    rcvind=ind[0]
;
    if n_elements(sigma)   eq 0 then sigma = 3.
    if n_elements(badfr)   eq 0 then badfr = .8
    if n_elements(verbose) eq 0 then verbose=0
    if n_elements(wait)    eq 0 then wait=0
;
;	warning... alfa now overlaps with lbw
;
	if n_elements(frange) eq 2 then begin
		f1=frange[0]
		f2=frange[1]
	endif else begin
    	f1=f1list[rcvind]
    	f2=f2list[rcvind]
	endelse
    if n_elements(han) eq 0 then han =1
    if n_elements(frqstep) eq 0 then frqstep=fstep[rcvind] 
    if n_elements(prefnm) eq 0 then prefnm=''

    if n_elements(outdir) ne 0 then begin
        outdirl=outdir
    endif else begin
        outdirl='/share/megs/rfi/rms/histdat/'
    endelse
    if strmid(outdirl,0,1,/reverse_offset) ne '/' then outdirl=outdirl+'/'
;
;   make the input filelist if they want
;
    if keyword_set(mklist) then rfihistlist,yymm,outdir=outdirl
;
;
;  loop over all the dates
;
    for i=0,n_elements(yymm)-1 do begin
        ym=yymm[i]
        inpfile=string(format='(a,"hlistinp.",i4.4)',outdirl,ym)
        line=string(format='("procfrq:",i4,"-",i5," file:",a)',f1,f2,inpfile)
        print,line
        nfiles=pfrfihist(inpfile,f1,f2,histinfo,histAr,$
            rcvlist=rcvlist[*,rcvind],sigma=sigma,binstep=frqstep,$
            verbose=verbose,han=han,wait=wait,rejectfr=badfr,$
			alfaBadBms=alfaBadBms)
;
;   save the files
;
        savnm=string(format='(a,a,"hsav_",i0,"_",i0,".",i4.4)',$
                        outdirl,prefnm,f1,f2,ym)
        save,histAr,histInfo,filename=savnm
    endfor
    return
end
