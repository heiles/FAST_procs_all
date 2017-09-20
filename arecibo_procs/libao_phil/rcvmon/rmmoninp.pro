;+
;NAME:
;rmmoninp - input the monitor data.
;
;SYNTAX: newrecs=rmmoninp(yymmdd,b,curpos=curpos,daynum=daynum,year=year,$
;                        append=append,inprecsize=inprecsize)
;DESCRIPTION:
;   This routine is called by rmmon to input the next set of monitor
;data.
;-
function rmmoninp,yymmdd,b,curpos=curpos,daynum=daynum,$
                   year=year,append=append ,inprecsize=inprecsize,$
					rcvmonstr=rcvmonstr
    forward_function julday,bytesleftfile
;
;  allocate array to hold entire day
;
    forward_function bin_date,yymmddtojulday

    if not keyword_set(curpos) then curpos=0L
    newrecs=0l
;   on_error,1
    on_ioerror,done
    if keyword_set(daynum) then begin
        if not keyword_set(year) then year=(bin_date())[0]
        dm=daynotodm(daynum,year)
        yymmddL=(year/100)*10000L + dm[1]*100+ dm[0]
    endif else begin
        if yymmdd lt 0 then begin
            a=bin_date()
            yymmddL=(a[0] mod 100)*10000L + a[1]*100+ a[2]
        endif else begin
            yymmddL=yymmdd
        endelse
        daynum=dmtodayno(yymmddL mod 100,yymmddl/100 mod 100,$
                         yymmddl/10000L + 2000)
    endelse
;	  a= {rcvMon, $
;         key        :   bytarr(4) ,$; 'rcv'
;         rcvNum     :   0B        ,$; receiver number
;         stat       :   0B        ,$; b0-lkshor,b1=hemtledA,b2:hemtledB
;         year       :   0         ,$; 4 digit year ast
;
;         day        :    0.D      ,$; day of year with fraction of day ast.
;
;         t16K   :         0.  ,$;
;         t70K   :         0.  ,$;
;
;         tomt   :         0.  ,$;
;         pwrP15     :         0.  ,$; dewar +15, -15
;
;         pwrN15     :         0.  ,$; dewar +15, -15
;         postAmpP15 :     0.      ,$; postAmp +15 volt supply
;         dcur       : fltarr(3,2) ,$;dewar bias currents[4amps, polA b]millamps
;         dvolts     : fltarr(3,2) };dewar Volts    [amp1-4, polA b] volts
	if keyword_set(rcvmonstr) then  begin
    	inprec=rcvmonstr
	endif else begin
    	inprec={rcvmon}
	endelse
    reclenB=n_tags(inprec,/len)
    inprecsize=reclenB
;
;    figure out the file to read
;
    lun=-1
    nfile=rmgetfile(yymmddL,yymmddL,filelist)
    if nfile eq 0 then goto,errout
	if ((lun=rmopenfile(filelist[0])) lt 0) then goto,done
    fstatd=fstat(lun)
;
;   position to last spot. if new file, position to start of day
;
    if curpos gt fstatd.size then curpos=0
    if curpos gt 0 then begin       ; just position to where we left off
        point_lun,lun,curpos
    endif else begin
        istat=rmposday(lun,yymmddL) ; position to start of day
;
;           0 - data in file starts after date. position at start
;           1 - date in file, or file empty   . position start of date
;           2 - data in file does not contain date . position at end
    endelse
    point_lun,-lun,curposStart
    bytesLeft=bytesleftfile(lun)
    recsToRead=bytesLeft/recLenB
    if recsToRead gt 0L then begin
        bloc=''
        didio=0
        if (n_elements(b) gt 0) and (keyword_set(append)) then  begin
            newrecs=rminprecs(lun,recsToRead,bloc)
            if newrecs gt 0 then begin
                ind=where(fix(bloc.day) eq daynum,count)
                if count eq 0 then begin    ; new day, old data
                    newrecs=0
                    goto,doagain
                endif
                if count ne newrecs then begin
                    bloc=bloc[ind]
                    newrecs=count
                endif
                b=[b,bloc]
                ind=where(long(b.day) eq dayNum,count)
                if count ne n_elements(b) then b=b[ind]
            endif
        endif else begin
           newrecs=rminprecs(lun,recsToRead,b)
           if newrecs gt 0 then begin
              ind=where(fix(b.day) eq dayNum,count)
;
;             read data, old day, but new date, we'll do it again
;
              if count eq 0 then begin  ; new day, old data
                    newrecs=0
                    goto,doagain
              endif
              if count ne n_elements(b) then begin
                b=b[ind]
                newrecs=count
              endif
           endif
        endelse
    endif
    point_lun,-lun,curpos
done: if lun ne -1 then free_lun,lun
    return,newrecs
doagain:
    newrecs=0
    point_lun,lun,curposStart
    goto,done
errout:
     if lun ne -1 then free_lun,lun
     return,-1
end
