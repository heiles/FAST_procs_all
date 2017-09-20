;+
;NAME:
;masrdrsatdec - decimate, peak hold radar saturation dataset
;SYNTAX: masrdrsatdec,todec,tpcln,tprdr,tpclnDec,tpRdrDec,medClnDec,medRdrDec,nptsD,indAr
;ARGS:
;   todec: long  sample to peak hold/decimate
;tpCln[npnt,nbeam]: float total power data clean band
;tpRdr[npt,nbeam,nrdr]: float peak power from rdr band
;RETURNS:
;tpClnDec[npnt/todec,nbeam]: float smoothed, decimated clean band
;tpRdrDec[npnt/todec,nbeam,nrdr]: float peak held rdr band
;medClnDec[npnt/todec,nbeam]: float median value of data before smoothing
;medRdrDec[npnt/todec,nbeam,nrdr]:  median value of data before smoothing
;nptsD: long    number of points each beam after smooth,decimate.
;indAr[npnt/todec]: long    indices into tpcln,tprdr (by beam) for the centers
;               of each smooth,decimated point. Use this to extact the 
;               za info from the za arr.
;DESCRIPTION:
;   boxcar smooth and then decimate the total power clean band. Do a 
;peak hold over the same channels for the radar samples.
;-
;
; create subset of za or az swing
;
pro masrdrsatdec,todec,tpcln,tprdr,tpclnDec,tpRdrDec,medClnDec,medRdrDec,nptsD,ii
;
    a=size(tpcln)
    npts=a[1]
    nbeams=(a[0] eq 1)?1:a[2]
    a=size(tpRdr)
    nrdr=(a[0] eq 3)?a[3]:a[2]
;
;   
    nptsD=(long(npts)/todec)            ; after decimation/smoothing
    nptsU= nptsD*todec          ; to  use
    tpClnDec=fltarr(nptsD,nbeams)
    tpRdrDec=fltarr(nptsD,nbeams,nrdr)
    medClnDec=fltarr(nptsD,nbeams)
    medRdrDec=fltarr(nptsD,nbeams,nrdr)
    for ibm=0,nbeams-1 do begin
        tpClnDec[*,ibm]=total(reform(tpCln[0L:nptsU-1,ibm],todec,nptsD),1)/todec
        medClnDec[*,ibm]=median(reform(tpCln[0L:nptsU-1,ibm],todec,nptsD),dim=1)
        for irdr=0,nrdr-1 do begin
            tpRdrDec[*,ibm,irdr]=$
                max(reform(tpRdr[0L:nptsU-1L,ibm,irdr],todec,nptsD),dim=1)
            medRdrDec[*,ibm,irdr]=$
                median(reform(tpRdr[0L:nptsU-1L,ibm,irdr],todec,nptsD),dim=1)
        endfor
    endfor
;
;   indices into original array for centers
;
    ii=lindgen(nptsD)*todec + (long(todec/2))
    return
end
