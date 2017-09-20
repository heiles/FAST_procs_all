;+
;NAME:
;dwtempinp - input dewar temps for a year
;SYNTAX: stat=dwtempinp(d,year=year,rcv=rcv)
;ARGS:   none
;KEYWORDS:
;   year    : int   4 digit year to input. default current year
;                   year='' will also input current year..
;   rcv     : string rcvname if supplied then just return this receiver
;                    rcvr names are:
;                   '430','lbw','lbn','sbw','sbn','sbh','cb','xb' 
;RETURNS:
;   d[] : {dwtemp}  dwtemp struct
;                   .nm string name 430,lbw,lbn,sbw,sbn,cb,xb,sbh
;                   .day double daynum of year (including fractional part) 
;                   .year    int  year (4 digits)
;                   .temp[3] float the 3 temps. 16,70,omt
;   stat: number of total entries found (dimension of returned d)
;DESCRIPTION:
;   Input  dewar temperatures for the year.This is the data recorded by
;the rmtempall routine that is run a few times a day by the operators.
;
;EXAMPLES:
;   To start idl:
;   idl
;   @phil
;   @dwinit
;   then 
;   print,dwtempinp(d)           .. input all the data for current year
;   print,dwtempinp(d,rcv='lbw') .. input current year lband wide only
;   print,dwtempinp(d,year=2001,rcv='lbn') .. input lbn for year 2001
;
;SEE ALSO:
;dwtempplot - to plot the data
;-
;   
function dwtempinp,d,year=year,rcv=rcv
;
    dir='/share/obs4/rcvm/'
    curyear=1
    if (n_elements(year) ne 0) then begin
        if year ne '' then curyear=0
    endif
    if curyear then begin
        a=bin_date()
        year=a[0]
    endif else begin
        dir=string(format='(a,i4)',dir,year)+'/'
    endelse
    if n_elements(rcv) eq 0 then rcv=''
    case rcv of
        '':
        '430': a=1
        'lbw': a=1
        'lbn': a=1
        'sbn': a=1
        'sbh': a=1
        'sbw': a=1
        'cb':  a=1
        'xb':  a=1
        else: begin
            printf,-2,'Illegal receiver name:',rcv
            return,0
            end
    endcase
    openr,lun,dir+'rmtempall.dat',err=ioerr,/get_lun
    if ioerr ne 0 then begin
        printf,-2,!err_string
        return,0
    endif
    a={dwtemp, nm : ' ',$;
               day: 0. ,$;
               year: 0 ,$;
              temp: fltarr(3)}
    maxentry=50000L
    d=replicate(a,maxentry)
    on_ioerror,done
    ind=0L
    day=0.D
    rec=0L
    intemp=0
    indate=0
    line=''
    while (1) do begin
        readf,lun,line
;       print,line
        rec=rec+1
        ch=strmid(line,0,1) 
        case ch of 
            's':begin               ; start line
                indate=1
                intemp=0
                end
            't':begin               ;temps line
                indate=0
                intemp=1
                end
            else:begin
                case 1 of 
                intemp: begin
                    a=strsplit(line,/extract)
                    if n_elements(a) ne 4 then begin
                        lab=string(format='("line:",i4," bad data:",a)',$
                        rec,line)
                        printf,-2,lab
                    endif else begin
                        if (rcv eq '') or (rcv eq a[0]) then begin
                        d[ind].nm=a[0]
                        d[ind].day=day
                        d[ind].year=year
                        d[ind].temp=float(a[1:3])
                        ind=ind+1 
                        endif
                    endelse
                    end
                indate : begin
                    a=bin_date(line)
                    day=dmtodayno(a[2],a[1],a[0])+ $
                        ((a[5]/60.D + a[4])/60.D + a[3])/24.D
                    end
                else: a=a
                endcase 
             end
       endcase
    endwhile
done:   
    free_lun,lun
    if ind gt 0 then d=d[0:ind-1]
    return,ind
end
