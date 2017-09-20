;+
;NAME:
;atmdcd - decode atm rawdat data
;SYNTAX: nipps=atmdcd(d,code,vdcd,nhghts,dcdh=dcdh,firsttime=firsttime,
;             use2ndchan=use2ndchan,usecal=usecal,
;             barkercode=barkercode,codelen88=codelen88,codelen52=codelen52)
;ARGS:
;d[n]:{rd}         array of rawdat structures to decode. These are 
;                  returned by atmget().
;code[codelen]:float  code to use (unless one of the codes has been specified
;                  with one of the code keywords.
;
;  KEYWORDS: 
;      dcdH:{}     decode structure holding info for future calls
;                  using the same data setup. It speeds up future
;                  calls by caching the transformed code and other info
;                  so they don't need to be compute each time.
; firstTime:       If set, then this is the first call with the data set.
;                  If provided, it will load dcdh with info to speed up
;                  future calls.
;use2ndchan:       if set then decode the 2nd chnannel of the data
;                  in d. By default the first channel is always decoded
;usecal    :       if set then include any cal samples in the decoding
;barkercode:       if set then ignore code[]. Program will generate the
;                  barker code and it  use for decoding.
;codelen88 :       if set then ignore code[]. Program will generate the
;                  88 length code (1 usec meteor observations) and use it
;                  for decoding.
;codelen52 :       if set then ignore code[]. Program will generate the
;                  52 length code used for the dregion and use it for decoding.
;
;           RETURNS:
;             nipps:long    number of ipps decoded
;vdcd[nhghts,nipps]:complex the decoded voltages
;         nhghts   :long    number of heights decoded..
;              dcdh:{}     structure holding info to use to speed up
;                           calls after the first call. On the first call
;                           this is returned to the user. On succeeding 
;                           calls it is just an input parameter.
;
;DESCRIPTION:
;   Decode a number of ipps from atm rawdat. The user passes in data 
;from atmget as well as the code to use. The routine will decode the
;ipps and pass the decoded voltages back in vdcd. 
;
;   The program has 3 built in codes. If you set the keyword that corresponds
;to one of these codes, then the program will generate the code for you
;(and it will ignore whatever you pass in via code). On return, code()
;will contain the generated code.
;
;   When decoding you need to zero extend and transform the code. If you
;are decoding many records with the same kind of data, you only need to compute
;the spectrum of the code once. The program lets you do this by:
;
;1. On the first call the user sets firsttime=1  and puts
;   dcdh=dcdh on the call so atmdcd can return info in it.
;
;2. atmdcd zero extends and transforms the code. It places this and
;   other info into dcdh which then gets passed back to the user.
;
;3. On subsequent calls the user sets firsttime=0 and passes in dcdh=dcdh.
;
;4. atmget just grabs the cached info from dcdh rather than recomputing
;   it.
;   
;   If you change the data type (hghts, codelen,code, txsamples, channel
;to decode, then you must set firsttime=1 again to recompute the new
;parameters.
;
;   Description of dcdh structure:
;
;  dcdh.CODELEN  LONG      52 Length of code used
;  dcdh.FFTLEN   LONG     512 length of fft used for decoding
;  dcdh.DCDHGHTS LONG     349 number of fully decoded hghts
;  dcdh.SMPTX    LONG       0 number of tx samples
;  dcdh.SMPHGHT  LONG     400 number of sample heights
;  dcdh.SMP1IPP  LONG     400 number of samples in ipp
;  dcdh.IPPSREC  LONG       4 number of ipps in record
;  dcdh.INDFIFO  INT        1 index into d.(indfifo) for data buf to use
;  dcdh.FFTSCALE FLOAT 262144. scaling factor for fft (fftlen)^2
;  dcdh.SPCCODE  COMPLEX  Array[512] zero exteneded transformed code,conjugated
;                             and then scaled by fftscale.
;
;   If this is too confusing, just ignore firsttime= and dcdh=. Everything
;will work ok but it'll run a lot slower since it recomputes the code on
;each call.
;
;   The last codelen-1 heights are not decoded (since all the data is not
;present). The returned array holds hghts:
;   0 through Nhghts-(codelen-1) heights
;
;   If a cal is present, then the /usecal keyword will cause the cal
;samples to be included in the decoding (this is how the old power profile
;program decoded the data).
;
;EXAMPLES:
;   1. loop calling atmget and atmdcd. Assume that the data was coded
;      with the 52 length d region code. Don't bother to remove the
;      digitizer offsets. Assume there are 4 ipps/record and that you
;      want 256*300 ipps to process:
;      the data.
;
;   firsttime=1                   
;   recPerRead=100          ; read 100 records per atmget call
;   nreads=100              ; read 100 records per atmget call
;   ip=0L
;   for i=0,nreads-1 do begin
;       istat=atmget(lun,d,nrec=recPerRead,/search)
;       nipps=atmdcd(d,code,vdcd,nhght,/codelen52,firsttime=firsttime,dcdh=dcdh)
;       firsttime=0                    ; after 1st time use dcdh.
;       if i eq 0 then begin            ; first time allocate volt array    
;         ippsTot=nreads*recPerRead*d[0].h.ri.ippsperbuf        
;         vAr=complexarr(nhght,ippsTot)
;       endif
;       vAr[*,ip:ip+nipps-1]=vdcd
;       ipp+=nipps
;   endfor
;
;   The var[ndcdhghts:349,ippsTot:40000.] will use 112 megabytes.
;
;NOTES:
;   The current scaling for atmdcd() will decode a code of unit height to
;a single range of amplitude codelen.
;-
function atmdcd,d,code,vdcd,nhghts,dcdh=dcdh,firsttime=firsttime,$
              use2ndchan=use2ndchan,usecal=usecal,$
             barkercode=barkercode,codelen88=codelen88,codelen52=codelen52
;
;        
    if keyword_set(firsttime)  or (n_elements(dcdh) eq 0) then begin
        smpTx  =d[0].h.sps.smpInTxPulse
        smpHght=d[0].h.sps.rcvwin[0].numSamples  ; just use first rcv window
        if keyword_set(usecal) then begin
            if (d[0].h.sps.numrcvwin eq 2) then begin
                smpHght=smpHght+ (d[0].h.sps.rcvwin[1].numsamples)
            endif
        endif
        smp1ipp= d[0].h.ri.smppairipp
        ippsRec= d[0].h.ri.ippsPerBuf
        gw     = d[0].h.sps.gw
    ;
;
;       see if they specified a code to use:
;
        case 1 of 
            
        keyword_set(barkercode): begin
                    code=[1., 1., 1.,1.,1.,-1.,-1.,1.,1.,-1.,1.,-1.,1.]
                end
        keyword_set(codelen88): begin
                    code=[$
  1.,-1.,-1., 1.,-1.,-1.,-1.,-1.,-1., 1., 1., 1.,-1., 1., 1.,-1.,-1., 1.,-1.,$
  1., 1.,-1.,-1.,-1., 1.,-1.,-1., 1., 1.,-1., 1.,-1., 1., 1., 1., 1.,-1., 1.,$
 -1., 1.,-1., 1., 1., 1.,-1.,-1.,-1.,-1.,-1.,-1., 1.,-1.,-1., 1.,-1., 1.,-1.,$
 -1.,-1.,-1.,-1.,-1., 1.,-1., 1., 1.,-1.,-1., 1., 1., 1.,-1.,-1.,-1., 1.,-1.,$
  1., 1.,-1.,-1., 1., 1., 1.,-1.,-1.,-1., 1.,-1.]
                   end
        keyword_set(codelen52): begin
                    code=[$
 -1,-1, 1,-1,-1,-1,-1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1, 1,$
  1,-1, 1, 1,-1,-1, 1,-1, 1,-1,-1, 1,-1,-1,-1, 1, 1, 1, 1,-1,-1, 1,-1,-1,$
 -1,-1, 1, 1]
                   end
              else: begin
                    end
        endcase
        codelen=n_elements(code)
;
;       make fftlen a power of 2
;
        ipow2=0L
        itemp=smpHght
        while (itemp gt 1) do begin &$
            itemp=itemp/2 &$
            ipow2=ipow2+1 &$
        endwhile
        if (2L^ipow2) lt smpHght then ipow2=ipow2+1
        fftlen=2L^ipow2
        fftScale=fftlen*1.
        spccode=fft([conj(complex(code,0)),complexarr(fftlen-codelen)])*$
                    fftscale
        spccode=conj(spccode)
        dcdHghts=smpHght - (codelen-1)
        indfifo =(keyword_set(use2ndchan))?2:1
        dcdh={ codelen : codelen,$
               fftlen  : fftlen ,$
               dcdHghts: dcdHghts,$ ; number of complete decoded heights
               smpTx   : smpTx   ,$ ; number of tx samples
               smpHght : smpHght ,$ ; number to use for decoding
               smp1ipp : smp1ipp ,$ ;total samples 1 ipp 
               ippsRec : ippsRec ,$ ; ipps 1 record read
               indFifo : indFifo,$  ; 1 for first fifo, 2 for 2nd
               fftScale: fftScale,$ ; for scaling decoded data
               spccode : spccode}   ; zeroextended, transformed code
    endif
;
    nrecs=n_elements(d)
    ippsTot=dcdh.ippsrec* nrecs
    vdcd =complexarr(dcdh.dcdHghts,ippsTot)  ; decode data goes here
    v    =(reform(d.(dcdh.indFifo),dcdh.smp1ipp,ippsTot))$
                [dcdh.smpTx:dcdh.smpTx+dcdh.smpHght-1,*]
    b    =complexarr(dcdh.fftlen)
    i2   =dcdh.smpHght-1L
    for i=0L,ippsTot-1 do begin
        b[0:i2]=v[*,i]
        vdcd[*,i]=(fft(fft(b)*dcdh.spccode,1))[0:dcdh.dcdHghts-1]   
    endfor
    nhghts=dcdh.dcdHghts
    return,ippsTot
end
