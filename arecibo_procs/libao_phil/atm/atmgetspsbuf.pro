;+
;NAME:
;atmgetspsbuf - input an spsbuf from an sps setup file
;SYNTAX: istat=atmgetspsbuf(lun,ctrlI,bufstate,buffreq,tmUnit=tmUnit)
;
;ARGS: lun    : of file to read.
;RETURNS:
;   ctrlI     : {} structure holding the control info
;   bufstat[16,n]: long  state buffer. n is duration of the buffer in
;   buffreq[n]: long   freq buffer. n is duration of the buffer in
;                     master clock units (usually 10Mhz)
;   tmUnit    : float .. (usecs) time step for a transition. It is normally
;                        1 usec unless the user has asked for a transition
;                        less than 1 usec.
;   
; RETURNS:
;  istat : int
;           1 - read buffer ok
;           0 - unable to read buf
;DESCRIPTION:
;   Read in an sps buffer that is used for datataking. The file
;names are typically: rawDat.tpsd.sps.cur ; ;-
; modification history:
; 28oct03 - started
;
function  atmgetspsbuf, lun, ctrlI,bufState,bufFreq,tmUnit=tmUnit

;
;   on_error,1
;
    on_ioerror,endofbuf
    ctrlI={ len             : 0L ,$;
            mclkdiv         : 0L ,$;
            s0clkdiv        : 0L ,$;
            s1clkdiv        : 0L ,$;
            ctrlStart       : 0L ,$;
            trig            : 0L }
    inpDat=ulonArr(2,8192)
    inpDat[1,*]='ffffffff'xul
    rew,lun
    inpLine=''
    print,'hi 1'
    while ( not eof(lun) ) do begin
        readf,lun,inpLine   
        print,inpline
        if strmid(inpLine,0,1) ne '#' then begin
        case 1 of 
              strmid(inpLine,0,3) eq 'len': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.len=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 'mcl': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.mclkdiv=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 's0c': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.s0clkdiv=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 's1c': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.s1clkdiv=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 'ctr': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.ctrlStart=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 'tri': begin
                    a=strsplit(inpLine,len=len)
                    ctrlI.trig=long(strmid(inpLine,a[1],len[1]))
                    end
              strmid(inpLine,0,3) eq 'dat': begin
                itemp=ulonarr(2)
                for j=0,8191 do begin
                    readf,lun,itemp ,format='(z,d)'
                    inpDat[*,j]=itemp
                endfor
                end
              else : begin
                    print,'unknown ctrl line:'+inpLine
                    goto,errout
                    end
        endcase
        endif
    endwhile
endofbuf:
        ind=where(inpDat[1,*] eq 'ffffffff'xul,count)
        numTrans=(count eq 0) ?8192: ind[0]
        minstate=min(inpdat[1,0:numTrans-1])
        div=(minState +1 ) lt  10? minState+1L:10L
        tmUnit=div/10.
        durTot=(total(inpDat[1,0:numtrans-1])+ numTrans)/div
        bufState=bytarr(durTot,16)
        buffreq =complexarr(durTot)
        j=0L
        for i=0l,numTrans-1 do begin
            len=(inpDat[1,i]+1)/div
            for k=0,15 do bufstate[j,k]=(ishft(inpDat[0,i],-k)  and 1)
            cos=(ishft(inpDat[0,i],-16) and 'ff'x)-128.
            sin=(ishft(inpDat[0,i],-24) and 'ff'x)-128.
            buffreq[j] =complex(cos,sin)
            for k=1,len-1 do begin
                buffreq[j+k]=buffreq[j]
                bufstate[j+k,*]=bufstate[j,*]
            endfor
            j=j+len
        endfor
    return,1
errout: return,0
end
