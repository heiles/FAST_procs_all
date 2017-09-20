;+
;NAME:
;pdevfileInfo - get file info
;SYNTAX: istat=pdevfileInfo(filename,pdevfI) 
;ARGS:
;   filename: string    name of pdev file
;RETURNS:
;pdevfI: {}     file info structure;
;-
function pdevfileinfo,filename,pdevfi
;
    istat=pdevopen(filename,desc)
    if istat ne 0 then return,0
    free_lun,desc.lun
;
    pdevFi={pdevfi,$
        fnmI    :desc.fnmI,$
        beam    : 0  ,$
        subband : 0  ,$
        fftlen  : 0L ,$
        nsbc    : 0L ,$
        nchan   : 0L ,$ ; actually dumped
        bw      : 0. ,$ ; Mhz
       dataBytes: 0  ,$ ;1,2,4
       blkSize  : 0L ,$
     nBlksReq   : 0L ,$
       dumpTm   : 0. ,$
       integTm  : 0. ,$ not including blanking
       totTmReq : 0.,$
        hdrSp   : desc.hsp } 
;
    pdevFi.fnmI=desc.fnmI
    pdevFi.beam=desc.hdev.beam
    pdevFi.subband=desc.hdev.subband
    pdevFi.fftlen =desc.hsp.fftlen
    pdevFi.nchan  =desc.nchan
    pdevFi.nsbc   =desc.nsbc
    pdevFi.bw     =desc.hdev.adcf*1e-6
    pdevFi.dataBytes=(desc.hsp.fmtwidth eq 0)?1:$
                     (desc.hsp.fmtwidth eq 1)?2 :4
    pdevFi.blkSize =desc.hdev.blksize
    pdevFi.nblksReq=desc.hdev.nblksdumped
    tm1fft=desc.hsp.fftlen*(1D/desc.hdev.adcf)
    pdevFi.dumpTm  =(desc.hsp.fftaccum+desc.hsp.fftdrop)*tm1fft
    pdevFi.integTm =(desc.hsp.fftaccum)*tm1fft
    pdevFi.totTmReq=pdevFi.dumpTm*pdevFi.nblksReq
    pdevFi.hdrSp   =desc.hsp
    return,1
end
