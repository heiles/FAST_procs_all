;+
;NAME:
;bdwf_hrmakeimage - make image, output to bin file and ascii hdr
;SYNTAX: bdwf_hrmakeimage,savDirNm,savInpNm,yyymmdd,srcToGet,freqChanToAvg,pol,
;  			baseline=baseline,
;           img_tf=img_tf,tmI=tmI,freqI=freqI
;ARGS:
;savDirNmr  : string directory to read the save file, and where to write
;                    the hdr and binary files.
;savInpNm   : string name of input save file (without the directory).
;yyyymmdd   : long   date. becomes part of output filename
;srcToGet   : string srcname. becomes part of output filename
;freqChanToAvg:long  number of frequency channels to avg. eg 64,or 128
;pol        : int    1..4 (stokes i,q,u,v) make,store image of this pol
;KEYWORDS:
;baseline:    int    0--> baseline the  image after combining the 7 bands
;                    1--> baseline each of the 7 bands separately
;                         (this is the default) 
;RETURNS:
;img_tm[ntm,nfrq]:float  created image
;tmI[ntm]     :float   time (counting from 0) for each spectra in the image.
;freqI[nfrq]  :float   freq channels for the image (Mhz).
;DESCRIPTION:
;	1.input the save file created by bdwf_hrmakesavefile.
;   2.make a dynamic spectra image for the specified polarization (1..4)
;     - combine all 7 frequency channels
;     - average, decimate in frequency
;     - interpolate to a fixed frequency grid
;     - write the binary image and ascii header to two files
;	 The output file names will be :
;
;		   binfileNm=savDirNm + srcToGet + "_polN_.bin"
;		   hdrfileNm=savDirNm + srcToGet + "_polN_.hdr"
;-
pro bdwf_hrmakeimage,hrI,freqChanToAvg,pol,baseline=baseline,$
           img_tf=img_tf,tmI=tmI,freqI=freqI

	savfileinp=hrI.savfileNms[0]
;
	lyyyymmdd=string(format='(i08)',hrI.yyyymmdd)
	binOutFile=hri.srcToGet + "_" + lyyyymmdd
;
; freq chan to avg
;
;	freqChanAvg=64
; stokes V
;	pol=4
; baseline each of 7 bands separately. &$ &$
; 0 --> baseline only the combined image
	if n_elements(baseline) eq 0 then 	baseline=1
	median=0
	istat=bdwf_hrsmointerpscan(savfileinp,freqchanToAvg,tmI,freqI,img_tf,$
		pol=pol,median=median,baseline=baseline)
;
; -----------------------------------------------------------------
; output image to disc along with hdr
;
	bdwf_hrmakebin,hrI,freqI,img_tf,pol,baseline,binOutFile
;
	return
end
