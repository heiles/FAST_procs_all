;+
;NAME:
;bdwf_hrmakebin - make binary image file
;SYNTAX: bdwf_hrmakebin,hrI,freqI,img_tf,pol,baseline,fnamePre
;ARGS:
;hri        :{}       struct holing info. 
;freqI[m]   : float   frequency for each channel of image
;img_tf[n,m]: float   n=#tmsteps,m=#freq bins. image to store
;pol        : int      1..4 which pol (i,q,u,v)
;baseline   : int     how the 7 (170 Mhz) bands were baselined
;                     0= all bands at once together
;                     1= each band was baselined separately
;fnamePre   : string  prefix for filnames
;
;DESCRIPTION:
;	write dynamic spectra for a single polarization to a binary file.
;Also output an ascii header file
;Example:
;	pol=4 ; stokesV 
;   baseline=0
;   fnamePre="TVLM513_20140523"
;
;   freqI,img_tf will come from the call to bdwf_hrsmointerpscan.
;
;   bdwf_hrmakebin,hri,freqI,img_tf,pol,baseline,fnamePre
;
;	will generate the files:
;  TVLM513_20140523_pol4.bin
;  TVLM513_20140523_pol4.hdr
;  in the hrI.savDirNm  directory
;-
pro bdwf_hrmakebin,hrI,freqI,img_tf,pol,baseline,fnamePre
;
;   restore savefile to get header info
;
;	restore,savfileinp
	lpol=string(format='("_pol",i1)',pol)
	binNm=hrI.savDirNm + fnamePre + lpol + ".bin"
	hdrNm=hrI.savDirNm + fnamePre + lpol + ".hdr"
	openw,lunout,binNm,/get_lun
	writeu,lunout,img_tf
	free_lun,lunout
;
;  now the header
;
	openw,lunout,hdrNm,/get_lun
;
	lnOut="#Bin data format. 4byt floats: freq0 tmSmp1..N, freq1 tmSmp1..N...etc"
	printf,lunout,lnOut
;
;  srcnm
	lnOut="#SrcNm"
	printf,lunout,lnOut
	srcNm=hrI.hdrI.object
	printf,lunout,srcnm

;   yyyymmdd  sssss

	lnOut="#DateUtc: yyyymmdd  SecMidUtc:ddddd"
	printf,lunout,lnOut
	yyyymmdd=hrI.hdrI.yyyymmddUtc
	lnout=string(format='(i08)',hrI.hdrI.yyyymmddUtc)
	lnOut=lnOut + " " + string(format='(i5)',long(hrI.hdrI.secMidUtc))
	printf,lunout,lnOut
;
;  tmStepSec nsteps
;
	lnOut="#tmStepSec nsteps"
	printf,lunout,lnOut
	nrows=hrI.hdrI.nrows
	ndmp =hrI.hdrI.ndumps
	nspc=nrows*ndmp 
	lnOut=string(format='(f11.8,2x,i4)',hrI.hdrI.tmStp,nspc)
	printf,lunout,lnOut
;
;  firstFrq freqStep Nfreq (all Mhz)
; &$
    lnOut='#firstFrqMhz freqStepMhz Nfreq '
	printf,lunout,lnOut
	lnOut=string(format='(f16.6,1x,f16.9,1x,i4)',freqI[0],freqI[1]-freqI[0],n_elements(freqI))
	printf,lunout,lnOut
;
;  baseline
;
    lnOut='#baseline 1= each band, 0= all bands at once'
    printf,lunout,lnOut
    lnOut=string(format='(i1)',baseline)
    printf,lunout,lnOut
;
;  pol
;
    lnOut='#pol 1=I,2=Q,3=u,4=V'
    printf,lunout,lnOut
    lnOut=string(format='(i1)',pol)
    printf,lunout,lnOut
	free_lun,lunout
	print,"Bin data written to :"+binnm
	print,"hdr data written to :"+hdrnm

	return
end
