;+
;NAME:
;galpwr - return power information for a number of recs
;SYNTAX: nrecs=galpwr(desc,reqrecs,pwra,lasthdr,b=b,useb=useb,wb=wb)
;ARGS:
;   desc     - descriptor opened via wasopen.
;   reqrecs  - requested records to return
;
;KEYWORDS:   
;   wb       - if set then return power from wideband data
;   useb     - if set then the user passes the data in via b= keyword.
;              desc is ignored and no data is read from disc
;   b[nrecs] - This can be an input and an output keyword. If /useb is
;              set, then the user is passing in the spectral data in the
;              b=b keyword (which means you need to have previously read
;              it). If /useb is not set, but b=b is provided, then the
;              spectral data read in will be returned in b.
;
;RETURNS:
;   pwra     - returns an array pwra[nrecs]  of {corpwr} struct
;   nrecs    - number of recs found, 0 if at eof, -1 if hdr alignment/io error
;   b[nrecs] - if keyword b= is supplied, then the input spectral data will
;              be returned in this keyword.
;
;DESCRIPTION:
;
;   Return the total power information for the requested number of
;records of a galfa file. The data is returned in the array pwra. 
;Each element of thearray contains:
;
;pwra[i].scan - scan number.. this is 0 for galfa:
;pwra[i].rec  - record number in the file (count from 1)
;pwra[i].time - seconds from midnight for this record
;pwra[i].nbrds- number of boards in use
;pwra[i].az   - az (deg) end of this record.
;pwra[i].za   - za (deg) end of this record.
;pwra[i].azErr- az (asecs great circle) . not available galfa
;pwra[i].zaErr- za (asecs great circle) . not available galfa
;pwra[i].pwr[2,8] - total power info. first index in pol1,pol2
;                   2nd index are 8 pixelss (only the 1st 7 are used with
;                   galfa.
;
;There will only be valid data in the first pwra[i].nbrds entries of
;pwra.
;
;EXAMPLES:
;;
;; 1. get the pwr from the entire file
;   rew,desc 
;   nrecs=galpwr(desc,600,p)
;
;; 2. same thing but also return the spectral records for later use 
;
;   rew,desc 
;   nrecs=galpwr(desc,600,p,b=b)
;
;; 3. use the spectra data in b we read from 2. to now get the
;;    wide band data. This is quicker since we don't have to re read
;;     all the spectral data.
;   nrecs=galpwr(desc,600,pwb,b=b,/useb)
;
;; 4. read in the spectral data with corgetm and the compute the power.
;    istat=corgetm(desc,600,b)
;    nrecs=galpwr(desc,600,p,/useb,b=b)
;
;-
;history:
;14jul05 - stole from waspwr()
;
function galpwr,desc,reqrecs,pwra,lasthdr,b=b,useb=useb,wb=wb
    on_error,0

    nrecs=reqrecs
    if not keyword_set(useb) then begin
        nrecs=(nrecs < desc.totrecs)
        istat=corgetm(desc,nrecs,b)
        if n_tags(b) eq 0 then return,0
    endif
    nrecs=(reqrecs < n_elements(b))
    pwra=replicate({corpwr},nrecs)
;
;   time Ast
;
    pwra.time =b.b1.h.std.time
    pwra.az   =b.b1.h.std.azttd*.0001
    pwra.az   =b.b1.h.std.grttd*.0001
    pwra.nbrds=7
    pwra.rec  =b.b1.h.std.grpnum
    nlags=keyword_set(wb)?512:b[0].b1.h.cor.lagsbcout
    if keyword_set(wb) then begin
        for ipix=0,6 do pwra.pwr[*,ipix]=total(b.(ipix).hf.g_wide)/nlags
    endif else begin
        for ipix=0,6 do pwra.pwr[*,ipix]=total(b.(ipix).d,1)/nlags
    endelse

;
    return,nrecs

hdrreaderr:
    print,'error reading fits hdr:',errmsg
    return,-1

end
