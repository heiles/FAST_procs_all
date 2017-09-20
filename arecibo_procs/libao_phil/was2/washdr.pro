;+
;NAME:
;washdr - read a was fits header
;
;SYNTAX: istat=washdr(desc,h,scan=scan,rec=rec,numhdr=numhdr,inc=inc)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;   scan: long     scan number default is current position in file
;    rec: long     record number of scan, default is current record
;    inc:          if set then increment position in file after reading
;                  the default is to do do no increment.
;    numhdr:       number of headers to read. default is 1
;
;RETURNS:
;   istat: int  1 ok, 0 eof,-1 bad (could not find scan or rec)
;       h: {wasfhdr}  was fits header
;
;DESCRIPTION:
;   This routine will read the fits headers on disc into a data structure.
;By default the header from the current row position is input. Multiple
;rows can be read with the numhdr keyword. You can position in the file
;before reading by using the scan, rec keywords. After the i/o the file
;is left positioned at the original position (on entry to this routine). The
;inc keyword will position the file after the last header read (be careful
;since  integrations or records may contain multiple rows in the file).
;
;Remember that a single integration (1 second) is made up of multiple
;headers or rows. For alfa it could be 8 pixels*2pol=16 headers/rec.
;
;WARNING:
;   This routine now uses mrdfits with a row range. It reads the header and
;spectral data for the requested number of headers in one call. Before
;returning it deletes the spectral data. So you need to be careful about 
;reading a large number of headers (say 1000's) at once. As a rule of thumb, 
;try and keep the number of headers read in 1 call to less than the number
;of rows in a typical scan (say 300*16). It is ok to  create large arrays of 
;these headers after the call, since the spectral data gets removed.
;
;-
function washdr,desc,rethdr,scan=scan,rec=rec,inc=inc,numhdr=numhdr
;
;   
;
    errmsg=''
    scanL=keyword_set(scan) ?scan:0L
    recL =keyword_set(rec)  ?rec :0L
    if scanL ne 0 then recL=1       
    if (scanL ne 0) or (recl ne 0) then begin
        if waspos(desc,scan,rec) ne 1 then begin
            print,"error positioning to scan,rec:",scanL,recL
            return,-1
        endif
    endif
    numhdrL=(keyword_set(numhdr))?numhdr:1L
    startPos=desc.curpos
    nrowsAvailable =(desc.totrows - startPos )
    if nrowsAvailable eq 0 then  begin
            print,"At end of file, no hdrs returned"
            return,0
    endif
    if (numhdrL gt nrowsAvailable) then begin
        lab=string(format='("--> returning only ",i," hdrs (hits eof)")',$
                nrowsAvailable)
        print,lab
        numhdrL=nrowsAvailable
    endif
;
;   try using mrdfits..
;   new to position to start of file, it will skip to start of row 
;
;   colList is the cols to return. It still reads the data col, it just
;   doesn't return it, so don't try to read in a million rows!!!
;
    colList=lindgen(desc.totCols-1)+2   ; skip first col(data) on returned
;                                       ..
    rew,desc.lun
    ext=1                               ; skip to first extension
    rows=[desc.curpos ,desc.curpos +numhdrL - 1]
    rethdr=mrdfits(desc.lun,ext,range=rows,columns=colList,status=status,$
            /silent)
    if status ne -1 then begin
        if keyword_set(inc) then desc.curpos=startPos + numhdrL
        return,1
    endif
    print,'Error reading header'
    rethdr=''
    return,-1
end
