;+
;NAME:
;mmgetparams - input mueller matrix for rcvr.
;
;SYNTAX:
;     istat=mmgetparams(rcvNum,cfr,mmparams,fname=fname,date=date)  
;
;ARGS:
;     rcvNum:  1 thru 16.  receiver to use (same as hdr.iflo.stat1.rfnum).
;        cfr: float freq in Mhz where the values should be computed.
;KEYWORDS:
;      fname: to specify an alternate data file with mueller matrix values.
;            The default file is aodefdir() + 'data/mm.datR{rcvNum}
;      date : [year,daynum]  .. if specified the data when you want the
;                              mueller matrix data for..default is most recent.
;
;RETURNS:
;      istat:  1 ok
;             -1 couldn't open file (probably no mueller data.
;   mmparams:{mmparam} return mueller matrix info.
;
;DESCRIPTION: 
;
;  Input the mueller matrix parameters and  for the receiver number rcvnum. 
;By default the data is read from the file:
;   aodefdir() + 'data/mm.datR{rcvNum} 
;aodefdir() is a function that returns the root of the aoroutines.
;The keyword fname lets you use an alternate file. The date keyword will
;search for data valid on or after this date (the default is to take the most
;recent data).
;
;   There is 1 file per receiver that holds the mueller matrix info for
;this receiver. Data blocks are defined by the date that they became
;valid. The datafile format is:
;
;  -  col 1 #     : this is a comment line. They can be anywhere in the file
;  - !yyyy daynum : this is the start of the data set for data valid on or 
;                   after yyyy daynum. !0 1 will work for any time in the past.
;  - end  in col 1: This marks the end of the dataset that started with the
;                   previous !yyyy daynum
;  - The lines between the !yyyy daynum and the "end" line are idl 
;    executable statements that define the parameters.
;
;   The input routine will scan the file looking for the date record that
;the person wants to use. It will then input 1 line at a time and execute
;them as idl statements (lines starting with # are ignored) until the
;line with "end" in cols 1-3 is found. These lines must define the following
;variables: alpha,epsilon,phi,chi,deltag,angle_astron,m_astron[4,4],
;circular, and corcal.
;An example file would look like:
;
;# following block valid starting on daynumber 145 of 2002 (25may02).
;#
;!2002 145
;alpha  = .25*!dtor
;epsilon= .0015
;phi    = -148.*!dtor
;psi    = -175.4*!dtor
;chi    =  90.*!dtor
;cfr20=cfr - 1420.
;deltag= 0.100 + 0.015* cos( 2.* !pi* cfr20/300.)
;angle_astron=-45.
;angle=angle_astron*!dtor
;m_astron=fltarr(4,4)
;m_astron[0,0] =1.
;m_astron[3,3] =-1.
;m_astron[ 1,1]= cos( 2.* angle)
;m_astron[ 2,1]= sin( 2.* angle)
;m_astron[ 2,2]= m_astron[ 1,1]
;m_astron[ 1,2]= -m_astron[ 2,1]
;corcal=1
;circular=0
;end
;# following block valid after daynumber 130 of 2001
;!2001 130 
;alpha  = .25*!dtor
;epsilon= .0015
;phi    = -148.*!dtor
;psi    = -175.4*!dtor
;chi    =  90.*!dtor
; ..
; ..
;end
;# valid for any time before daynum 130 of 2001
;!0 1
;alpha  = .25*!dtor
;epsilon= .0015
; ..
; ..
;end
;
;   These variables are then loaded into the mmparams (mueller matrix
;parameter structure. The structure format for {mmparams} is:
; mmp.rcvNum  int      receiver number
; mmp.year    int      year when this data becaume valid
; mmp.day     int      daynumber of year when this data became valid
; mmp.cirular int      1 if receiver is native circular
; mmp.corcal  int      1 if receiver has correlated cal
; mmp.cfr     float    frequency in Mhz where the parameters are computed.
;
; mmp.alpha   float    alpha parameter (in radians)
; mmp.epsilon float    epsilon parameter
; mmp.phi     float    phi angle in radians
; mmp.psi     float    psi angle in radians
; mmp.chi     float    chi angle in radians
; mmp.deltag  float    difference in cal values
; mmp.astronAngle float astronomical angle (degrees)
; mmp.m_astron[4,4] float matrix to apply after the mueller matrix
;                      correction to get to sky coordinates.
;SEE ALSO: 
;   AO technical memo 2000-05 (The Mueller matrix parameters for Arecibo's
;receiver systems. http://www.naic.edu/aomenu.htm

;- 
;history:
;16oct02 .. started
;04aug07 .. added loaded mmp.circular.
function mmgetparams,rcvNum,cfr,mmparams,fname=fname,date=date
;
    on_error,1
    on_ioerror,endio
    lun=-1
    if (n_elements(fname) eq 0) then begin
        fname=string(format='(a,"data/mm.datR",i0)',aodefdir(),rcvNum)
    endif
    case n_elements(date) of
        0   : begin
                reqYr =0
                reqDay=0
              end
        1   : begin
                reqYr =date[0]
                reqDay=0            
              end
        2   : begin
                reqYr =date[0]
                reqDay=date[1]
              end
        else: message,'mmgetparams illegal date request.. [year,daynum]'
    endcase
    openr,lun,fname,/get_lun,error=err
    if  err ne 0 then begin
        lab="error"+ string(err)+ " openning " + fname + '. no mueller data??'
        message,/info,!err_string
        message,/info,lab
        return,-1
    endif
;
;    file format is:
;  d1Ah d1Al d1Bh d1Bl d2Ah d2Al d2Bh d2Bl
; ; col 1 is comment
; !yyyy ddd is first valid date for data that follows..
;
    inpl=" "
    i=0
    gotDate=reqYr eq 0
    startYr=0L & startDay=0L
    endYr=0L   & endDay=0L
    while (1) do begin
        readf,lun,inpl
        if (strmid(inpl,0,1) ne '#') then begin
           if (strmid(inpl,0,1) eq '!') then begin
              if not gotDate then begin
                 startYr=0L & startDay=0l
                 reads,strmid(inpl,1,strlen(inpl)-1),startYr,startDay
                 if (startYr lt reqYr) or $
                    ((startYr eq reqYr) and (startDay le reqDay)) then begin
                        gotDate=1
                 endif else begin
                    endYr = startYr
                    endDay= startDay
                 endelse
              endif else begin
                 if i gt 0 then goto,endio
              endelse
              if (startYr eq 0 ) and (startDay eq 0) then begin
                   reads,strmid(inpl,1,strlen(inpl)-1),startYr,startDay
              endif
           endif else begin
                if gotDate then begin
                    if (strmid(inpl,0,3) eq 'end') then goto,endio
                    istat=execute(inpl)
                    if istat eq 0 then begin
                        lab=string(format=$
                            '("Reading file",a," line:",a)',fname,inpl)
                        free_lun,lun
                        message,lab
                    endif
                 endif
            endelse
        endif
    endwhile
;
;   load the variables they defined
;
endio:  
    mmparams={mmparams}
    mmparams.rcvnum=rcvnum
    mmparams.cfr   =cfr
    mmparams.year  =startYr
    mmparams.day   =startDay
    mmparams.alpha =alpha
    mmparams.epsilon=epsilon
    mmparams.phi    =phi
    mmparams.psi    =psi
    mmparams.chi    =chi
    mmparams.deltag =deltag
    mmparams.astronAngle=angle_astron
    mmparams.m_astron=m_astron
    mmparams.corcal  =corcal
    mmparams.circular=circular
    free_lun,lun
    return,1
end
