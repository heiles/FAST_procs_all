;+
;NAME:
;wappfilesizei - get file/ record size info
;SYNTAX: istat=wappfilesizei(lun,hdr,fszI,gethdr=gethdr)
;ARGS:
;   lun:    long      logical unit number for file to read
;   hdr:    {wapphdr} wapp header user passes in (see wappgethdr)
;RETURNS:
;   stat:   0  trouble with file, 1 got file size info ok
;   fszI: {fileszI}   return file sizeinfo structure
;
;DESCRIPTION:
;   Get the file size info for the file pointed to by lun. The user
;passes in the lun that is opened to the file of interest and the 
;hdr of this file (setting the keyword gethdr will read the header for
;you). The return info is:
;   fszI.bytesTot   - total bytes in the file
;   fszI.byteshdr   - bytes start of file to start of data.
;   fszI.bytesData  - total data bytes in the file
;   fszI.byresRec   - number of bytes in 1 rec
;   fszI.nrecs      - total number of samples in the file
;
;-
function wappfilesizei,lun,h,fszI,gethdr=gethdr
;     
;
;   some constants that belong in an include file
;   ADS_OPTM_3LEV=.6115059
;   ADS_OPTM_9LEV=.266916
;
    if keyword_set(gethdr) then begin
        istat=wappgethdr(lun,h)
        if istat ne 1 then return,0
    endif
    fszI={  bytesTot: 0UL   ,$; bytes in file
            bytesHdr: 0UL   ,$; bytes in hdr
            bytesData: 0UL  ,$; bytes of data
            bytesRec: 0UL   ,$; bytes in 1 sample
            nrecs   : 0UL   } ; samples in 1 file

    fst=fstat(lun)
    fszI.bytesTot=fst.size
    fszI.bytesHdr =h.byteOffData
    fszI.bytesData=fst.size-h.byteOffData 
    case (h.lagformat and 7) of
        0: bytelen=2
        1: bytelen=4
        2: bytelen=4
        3: bytelen=4
        else:begin
            print,'Unknown lagformat in hdr:',h.lagformat
            return,0
            end
    endcase
    nlags=h.num_lags
    nifs=h.nifs
    nbrds=(h.isalfa)?2:1
    fszI.bytesRec= nlags*nifs*nbrds*bytelen
    fszI.nrecs= fszI.bytesData/fszI.bytesRec
    return,1
end
