;+
;NAME:
;agcmoninp - input the monitor data.
;
;SYNTAX: newrecs=agcmoninp,yymmdd,b,curpos=curpos,daynum=daynum,year=year,$
;				 append=append,inprecsize=inprecsize
;DESCRIPTION:
;   This routine is called by agcmon to input the next set of monitor
;data.
;-
function agcmoninp,yymmdd,b,curpos=curpos,daynum=daynum,$
                   year=year,append=append ,inprecsize=inprecsize
    forward_function julday,bytesleftfile
;
;  allocate array to hold entire day
;
    forward_function bin_date,yymmddtojul
    if not keyword_set(curpos) then curpos=0L
    fpre='/share/obs1/pnt/log/cbFb'
    fsuf='.dat'
    newrecs=0l
;   on_error,1
    on_ioerror,done
    if keyword_set(daynum) then begin
        if not keyword_set(year) then year=(bin_date())[0]
        julday=daynotojul(daynum,year)
    endif else begin
        if yymmdd lt 0 then begin
            a=bin_date()
            julday=julday(a[1],a[2],a[0],0,0,0)
        endif else begin
            julday=yymmddtojulday(yymmdd)
        endelse
    endelse
    inprec={cbfbinp}
    reclenB=n_tags(inprec,/len)
    inprecsize=reclenB
;
;    create the filename to read
;
	yymmddL=string(format='(c(cyi2.2,cmoi2.2,cdi2.2))',julday)
	lun=agcopen(yymmddL)
    if lun lt 0 then goto,done
    fstatd=fstat(lun)
;
;   new day
;
    if curpos gt fstatd.size then curpos=0
    if curpos gt 0 then point_lun,lun,curpos
    bytesLeft=bytesleftfile(lun)
    recsToRead=bytesLeft/recLenB
    if recsToRead gt 0L then begin
        bloc=''
        didio=0
        if (n_elements(b) gt 0) and (keyword_set(append)) then  begin
               newrecs=agcinp(lun,bloc,recsToRead)
               if newrecs gt 0 then b=[b,bloc]
               didio=1
        endif
        if not didio then begin
           newrecs=agcinp(lun,b,recsToRead)
        endif
    endif
    point_lun,-lun,curpos
done: if lun ne -1 then free_lun,lun
    return,newrecs
errout:
     if lun ne -1 then free_lun,lun
     return,-1
end
