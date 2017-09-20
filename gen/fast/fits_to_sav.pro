pro fits_to_sav, path, filename, strout, freq, npol=npol 

;+
;FITS_TO_SAV.pro: read pulsar roach data which are sampled every
;   millisec, extract one of the 'polarizations', produce 1-sec profiles
;   by averaging 1000 of the original spectra. Write out the result in a
;   sav file.
;
;In its current form, the coordinates are specified below:
;   dec= ten(23, 34, 52.8) + fltarr( nrsp)
;   ra=lst
;
;
;INPUTS:
;   PATH, the subdir in which the file resides
;   FILENAME, the name of the file
;
;KEYWORD:
;   NPOL, the polarization to write out. npol=1 is the 1-2Gz
;   receiver. If you don't set npol, it defaults to 1.
;
;OUTPUT:
;   STROUT, the structure that is written to the output file
;   FREQ, the array of freqs one-to-one correspondence with spectral
;         chnls. NOTE for 1-2 GHz rx, the freq array is REVERSED.
;
;EFFECT:
;Writes an output file containing STROUT. The name of the output file is
;the name of the inputt file appended by '.sav'
;-

if n_elements( npol) eq 0 then npol=1

;find the time of the end (last datum) of the file...
filetimes, path, filename, jd0, ut0, lst0, t0

img= mrdfits( path + filename, 1 , hdr)

;stop

nrimg= n_elements(img)
sz= size(img.data)
nrchnls= sz[2]
nrpol= sz[3]
nrspct= sz[4]
nrtot= nrspct* nrimg

;freq in MHz, time in musec                                                                         
fsmpl=2048.d0
tsmpl=1./fsmpl
tmax=tsmpl*nrchnls
delt= tmax/nrchnls
bw=fsmpl/2
delf= bw/nrchnls

freq= delf* dindgen(nrchnls)
if npol eq 1 then begin
   freq= 1024. + freq
   freq= reverse( freq)
endif

time= delt* dindgen(nrchnls)
distance= 3.e8* time* 1.e-6

sp= reform( img.data[0, *, npol, *, *], 1, nrchnls, 1, nrtot)
sp= reform( sp)
szsp=size(sp)
nrsp= nrtot/1000l
sp= reform( sp, nrchnls, 1000l, nrsp)
sp_1sec= total( sp,2)/1000l

sptime= reverse( t0- lindgen( nrsp))
jd= reverse( jd0- dindgen( nrsp)/86400.d0)
dec= ten(23, 34, 52.8) + fltarr( nrsp)
lst= ilst( juldate=jd)
ra=lst

cont_mean= total( sp_1sec, 1)/4096
cont_median= median( sp_1sec, dim=1)

strout0= {nd:0, ndcycnr:0l, jd:jd0, spt:sptime[0], sp:sp_1sec[*,0], $
          cont_mean:cont_mean[0], cont_median:cont_median[0], $
          ra:ra[0], dec:dec[0], lst:lst[0]}
strout= replicate( strout0, nrsp)
strout.nd= 0
strout.jd= jd
strout.spt= sptime
strout.sp= sp_1sec
strout.cont_mean= cont_mean
strout.cont_median= cont_median
strout.ra= ra
strout.dec= dec
strout.lst= lst

save, strout, freq, file='fits_to_sav_' + filename + '.sav'
end
